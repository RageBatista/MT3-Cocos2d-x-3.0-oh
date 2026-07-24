//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.item.Pack;
import fire.pb.map.SceneManager;
import fire.pb.scene.movable.Role;
import fire.pb.scene.movable.SceneTeam;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.title.Title;
import fire.pb.util.BagUtil;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;

public class PJieHun extends Procedure {
    private final long roleId;
    private final Role role;
    private final int resilt;

    public PJieHun(long roleId, Role role, int resilt) {
        this.roleId = roleId;
        this.role = role;
        this.resilt = resilt;
    }

    protected boolean process() throws Exception {
        if (this.resilt == 1) {
            SceneTeam team = this.role.getTeam();
            if (team == null) {
                MessageMgr.sendMsgNotify(this.roleId, 191261, (List)null);
                return false;
            }

            if (team.size() != 2) {
                MessageMgr.sendMsgNotify(this.roleId, 191264, (List)null);
                return false;
            }

            ArrayList<Integer> list = new ArrayList();

            for(Role allTeammate : team.getAllTeammates()) {
                PropRole propRole = new PropRole(allTeammate.getRoleID(), true);
                Properties properties = xtable.Properties.get(allTeammate.getRoleID());
                if (properties.getPartnerid() > 0L) {
                    ArrayList<String> strings = new ArrayList();
                    strings.add(propRole.getName());
                    MessageMgr.sendMsgNotify(this.roleId, 191262, strings);
                    return false;
                }

                Pack itemBases = new Pack(allTeammate.getRoleID(), false);
                int bagItemNum = itemBases.getBagItemNum(400813);
                if (bagItemNum < 1) {
                    MessageMgr.sendMsgNotify(this.roleId, 191274, (List)null);
                    return false;
                }

                int sex = propRole.getSex();
                list.add(sex);
            }

            long roleID = ((Role)team.getMembers().get(0)).getRoleID();
            Properties inviterProperty = xtable.Properties.get(team.getCapitanRoleID());
            SInvitationToMarry snd = new SInvitationToMarry();
            snd.op = 0;
            snd.invitername = inviterProperty.getRolename();
            snd.inviterlevel = xtable.Properties.get(team.getCapitanRoleID()).getLevel();
            Procedure.psendWhileCommit(roleID, snd);
        }

        if (this.resilt == 2) {
            SceneTeam team = this.role.getTeam();
            if (team == null) {
                MessageMgr.sendMsgNotify(this.roleId, 191267, (List)null);
                return false;
            }

            if (team.size() != 2) {
                MessageMgr.sendMsgNotify(this.roleId, 191268, (List)null);
                return false;
            }

            Pack itemBases = new Pack(team.getCapitanRoleID(), false);
            Pack itemBases1 = new Pack(((Role)team.getMembers().get(0)).getRoleID(), false);
            if (itemBases.getBagItemNum(400814) < 1 || itemBases1.getBagItemNum(400814) < 1) {
                MessageMgr.sendMsgNotify(this.roleId, 191275, (List)null);
                return false;
            }

            long roleID = ((Role)team.getMembers().get(0)).getRoleID();
            if (BagUtil.removeItem(this.roleId, 400814, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结婚消耗") != 1) {
                return false;
            }

            if (BagUtil.removeItem(roleID, 400814, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结婚消耗") != 1) {
                System.out.println("离婚道具消耗错误！");
                return false;
            }

            PropRole propCapitanRole = new PropRole(team.getCapitanRoleID(), false);
            PropRole propRole = new PropRole(((Role)team.getMembers().get(0)).getRoleID(), false);
            Properties CapitanRoleproperties = xtable.Properties.get(team.getCapitanRoleID());
            Properties properties = xtable.Properties.get(((Role)team.getMembers().get(0)).getRoleID());
            if (CapitanRoleproperties.getPartnerid() != ((Role)team.getMembers().get(0)).getRoleID() || properties.getPartnerid() != team.getCapitanRoleID()) {
                MessageMgr.sendMsgNotify(this.roleId, 191269, (List)null);
                return false;
            }

            CapitanRoleproperties.setPartnerid(0L);
            properties.setPartnerid(0L);
            Title Capitantitle = new Title(team.getCapitanRoleID(), false);
            Title title = new Title(((Role)team.getMembers().get(0)).getRoleID(), false);
            Capitantitle.removeTitle(255);
            title.removeTitle(255);
            ArrayList<String> strings = new ArrayList();
            strings.add(propCapitanRole.getName());
            strings.add(propRole.getName());
            STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191270, 0, strings);
            SceneManager.sendAll(ssmn);
        }

        if (this.resilt == 3) {
            Pack itemBases = new Pack(this.roleId, false);
            if (itemBases.getBagItemNum(400815) < 1) {
                MessageMgr.sendMsgNotify(this.roleId, 191276, (List)null);
                return false;
            }

            if (itemBases.removeItemById(400815, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结婚消耗") != 1) {
                System.out.println("强制离婚道具消耗错误！");
                return false;
            }

            PropRole propRole = new PropRole(this.roleId, false);
            Properties propRoleproperties = xtable.Properties.get(this.roleId);
            long marryRoleId = propRoleproperties.getPartnerid();
            if (marryRoleId == 0L) {
                MessageMgr.sendMsgNotify(this.roleId, 191271, (List)null);
            }

            PropRole marryRole = new PropRole(marryRoleId, false);
            Properties marryRoleproperties = xtable.Properties.get(marryRoleId);
            marryRoleproperties.setPartnerid(0L);
            propRoleproperties.setPartnerid(0L);
            Title Capitantitle = new Title(marryRole.getRoleId(), false);
            Title title = new Title(propRole.getRoleId(), false);
            Capitantitle.removeTitle(255);
            title.removeTitle(255);
            ArrayList<String> strings = new ArrayList();
            strings.add(propRole.getName());
            strings.add(marryRole.getName());
            STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191272, 0, strings);
            SceneManager.sendAll(ssmn);
        }

        return true;
    }
}
