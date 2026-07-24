//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import fire.log.YYLogger;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.msp.role.GRoleModifyName;
import fire.pb.GsClient;
import fire.pb.PropRole;
import fire.pb.event.ModifyRoleNameEvent;
import fire.pb.event.Poster;
import fire.pb.item.Pack;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.ranklist.proc.PRankInsertPet;
import fire.pb.ranklist.proc.PRankInsertRoleChangeName;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.ranklist.proc.RankListManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.CheckName;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.List;
import mkdb.Procedure;
import mkdb.util.UniqName;
import xbean.FriendGroups;
import xbean.MarshalRoleLevelRecord;
import xbean.ModifyNameRole;
import xbean.Pod;
import xbean.Properties;
import xbean.RoleLevelListRecord;
import xbean.RoleLevelRankList;
import xtable.Friends;
import xtable.Modnameitemroles;
import xtable.Rolelevellist;
import xtable.Rolename2key;

public class PModifyRoleName extends Procedure {
    private long roleId;
    private String newName;
    private int itemkey;
    private boolean isGM;

    public PModifyRoleName(long roleid, String newName, int itemkey, boolean isGM) {
        this.roleId = roleid;
        this.newName = newName;
        this.itemkey = itemkey;
        this.isGM = isGM;
    }

    protected boolean process() throws Exception {
        if (this.roleId < 0L) {
            return false;
        } else if (!validRoleName(this.newName, this.roleId)) {
            return false;
        } else {
            Properties prop = xtable.Properties.get(this.roleId);
            if (prop == null) {
                return false;
            } else {
                String oldname = prop.getRolename();
                if (!this.isGM) {
                    int use = (new Pack(this.roleId, false)).removeItemWithKey(this.itemkey, 1, YYLoggerTuJingEnum.tujing_Value_gaiming, 0, "使用改名消耗");
                    if (use != 1) {
                        return false;
                    }
                }

                if (!prop.getUsedname().contains(this.newName)) {
                    String lowerCaseName = this.newName.toLowerCase();
                    if (!UniqName.allocate("role", lowerCaseName)) {
                        MessageMgr.psendMsgNotifyWhileRollback(this.roleId, 144664, (List)null);
                        return false;
                    }
                }

                ModifyNameRole modRole = Modnameitemroles.get(this.roleId);
                if (modRole == null) {
                    modRole = Pod.newModifyNameRole();
                    Modnameitemroles.insert(this.roleId, modRole);
                }

                modRole.setModcount(modRole.getModcount() + 1);
                modRole.setLastbuytime(System.currentTimeMillis());
                prop.setRolename(this.newName);
                if (!prop.getUsedname().contains(oldname)) {
                    prop.getUsedname().add(oldname);
                }

                Rolename2key.add(this.newName, this.roleId);
                MessageMgr.pbroadcastMsgNotify(170025, 0,Arrays.<String>asList(oldname, this.newName));
                FriendGroups groups = Friends.get(this.roleId);
                if (groups != null && groups.getFriendmap().size() != 0) {
                    MessageMgr.psendSystemMessageToRoles(groups.getFriendmap().keySet(), 170025, Arrays.asList(oldname, this.newName));
                }

                Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleId));
                final int level = prop.getLevel() + (prop.getZhuansheng() > 0 ? prop.getZhuansheng() * 1000 : 0);

                if (level >= 30) {
                    Procedure.pexecuteWhileCommit(new Procedure() {
                        public boolean process() {
                            RoleLevelListRecord record = Pod.newRoleLevelListRecord();
                            record.setTime(System.currentTimeMillis());
                            MarshalRoleLevelRecord marshRecord = record.getMarshaldata();
                            marshRecord.setLevel(level);
                            marshRecord.setRoleid(PModifyRoleName.this.roleId);
                            PropRole pRole = new PropRole(PModifyRoleName.this.roleId, true);
                            marshRecord.setRolename(pRole.getName());
                            marshRecord.setSchool(pRole.getSchool());
                            RoleLevelRankList list = Rolelevellist.get(1);
                            if (null == list) {
                                list = Pod.newRoleLevelRankList();
                                Rolelevellist.insert(1, list);
                            }

                            RankListManager.getInstance().tryInsertRecord(1, list.getRecords(), record);
                            return true;
                        }
                    });
                }

                PetColumn petColumn = new PetColumn(this.roleId, 1, false);

                for(Pet pet : petColumn.getPets()) {
                    Procedure.pexecuteWhileCommit(new PRankInsertPet(pet.getUniqueId(), true));
                }

                Procedure.pexecuteWhileCommit(new PRankInsertRoleChangeName(this.roleId));
                GRoleModifyName send = new GRoleModifyName();
                send.roleid = this.roleId;
                send.newname = this.newName;
                Team team = TeamManager.selectTeamByRoleId(this.roleId);
                if (team != null) {
                    send.teammembers.addAll(team.getAllMemberIds());
                }

                GsClient.pSendWhileCommit(send);
                Poster.getPoster().dispatchEvent(new ModifyRoleNameEvent(this.roleId, oldname, this.newName));
                YYLogger.rolNameLog(prop.getUserid(), this.roleId, 1);
                return true;
            }
        }
    }

    public static boolean validRoleName(String name, long roleId) {
        int nameLen = CheckName.nameLen();
        int length = 0;

        try {
            length = (new String(name.getBytes("gb2312"), "ISO-8859-1")).length();
        } catch (UnsupportedEncodingException var6) {
            MessageMgr.psendMsgNotifyWhileRollback(roleId, 145627, (List)null);
            return false;
        }

        if (length > nameLen) {
            MessageMgr.psendMsgNotifyWhileRollback(roleId, 145627, (List)null);
            return false;
        } else if (length < 4) {
            MessageMgr.psendMsgNotifyWhileRollback(roleId, 145627, (List)null);
            return false;
        } else {
            int resultCode = CheckName.checkValid(name);
            if (resultCode != 0) {
                MessageMgr.psendMsgNotifyWhileRollback(roleId, 144663, (List)null);
                return false;
            } else {
                return true;
            }
        }
    }
}
