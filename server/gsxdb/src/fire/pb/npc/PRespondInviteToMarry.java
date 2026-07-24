//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.common.SCommon;
import fire.pb.friends.FriendHelper;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
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
import xbean.FriendGroups;
import xbean.Properties;
import xtable.Friends;

public class PRespondInviteToMarry extends Procedure {
    private final Long roleid;
    private final Role role;

    public PRespondInviteToMarry(Long roleid, Role role) {
        this.role = role;
        this.roleid = roleid;
    }

    protected boolean process() throws Exception {
        SceneTeam team = this.role.getTeam();
        if (team == null) {
            MessageMgr.sendMsgNotify(this.roleid, 191263, (List)null);
            return false;
        } else if (team.size() != 2) {
            MessageMgr.sendMsgNotify(this.roleid, 191264, (List)null);
            return false;
        } else {
            Pack itemBases = new Pack(this.roleid, false);
            if (itemBases.getBagItemNum(400813) < 1) {
                MessageMgr.sendMsgNotify(this.roleid, 191274, (List)null);
                return false;
            } else {
                Pack itemBases1 = new Pack(team.getCapitanRoleID(), false);
                if (itemBases1.getBagItemNum(400813) < 1) {
                    MessageMgr.sendMsgNotify(this.roleid, 191274, (List)null);
                    return false;
                } else if (BagUtil.removeItem(this.roleid, 400813, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结婚消耗") == 1) {
                    if (BagUtil.removeItem(team.getCapitanRoleID(), 400813, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结婚消耗") != 1) {
                        System.out.println("结婚道具消耗错误！");
                        return false;
                    } else {
                        Title title = new Title(this.roleid, false);
                        Title Capitantitle = new Title(team.getCapitanRoleID(), false);
                        PropRole propRole = new PropRole(this.roleid, false);
                        Properties propRoleproperties = xtable.Properties.get(this.roleid);
                        PropRole propCapitanRole = new PropRole(team.getCapitanRoleID(), false);
                        Properties propCapitanRoleperties = xtable.Properties.get(team.getCapitanRoleID());
                        FriendGroups CapitanFriendGroups = Friends.get(team.getCapitanRoleID());
                        FriendGroups FriendGroups = Friends.get(this.roleid);
                        if (!FriendHelper.isBothwayFriend(CapitanFriendGroups, team.getCapitanRoleID(), FriendGroups, this.roleid)) {
                            MessageMgr.sendMsgNotify(this.roleid, 191266, (List)null);
                            MessageMgr.sendMsgNotify(team.getCapitanRoleID(), 191266, (List)null);
                            return false;
                        } else {
                            ArrayList<Integer> list = new ArrayList();
                            list.add(propRole.getSex());
                            if (!list.contains(propCapitanRole.getSex())) {
                                list.add(propCapitanRole.getSex());
                            }

                            propRoleproperties.setPartnerid(team.getCapitanRoleID());
                            propCapitanRoleperties.setPartnerid(this.roleid);
                            System.out.println("性别1" + propRole.getSex() + "性别2" + propCapitanRole.getSex() + "大小" + list.size());
                            if (list.size() < 2) {
                                if (propRole.getSex() == 1) {
                                    Capitantitle.addTitle(255, propRole.getName() + "的好基友", -1L);
                                    title.addTitle(255, propCapitanRole.getName() + "的好基友", -1L);
                                }

                                if (propRole.getSex() == 2) {
                                    Capitantitle.addTitle(255, propRole.getName() + "的闺蜜", -1L);
                                    title.addTitle(255, propCapitanRole.getName() + "的闺蜜", -1L);
                                }
                            } else if (propRole.getSex() == 1) {
                                title.addTitle(255, propCapitanRole.getName() + "的夫君", -1L);
                                Capitantitle.addTitle(255, propRole.getName() + "的娘子", -1L);
                            } else {
                                title.addTitle(255, propCapitanRole.getName() + "的娘子", -1L);
                                Capitantitle.addTitle(255, propRole.getName() + "的夫君", -1L);
                            }

                            SCommon conf = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(494);
                            int itemid = 0;
                            int itemnum = 0;
                            if (conf != null) {
                                String value = conf.getValue();
                                String[] split = value.split(";");
                                if (split.length == 2) {
                                    itemid = Integer.valueOf(split[0]);
                                    itemnum = Integer.valueOf(split[1]);
                                }
                            }

                            if (itemid != 0 && itemnum != 0) {
                                if (BagUtil.addItem(this.roleid, itemid, itemnum, "结婚赠送", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, itemid) != itemnum) {
                                    return false;
                                }

                                if (BagUtil.addItem(team.getCapitanRoleID(), itemid, itemnum, "结婚赠送", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, itemid) != itemnum) {
                                    return false;
                                }
                            }

                            ArrayList<String> strings = new ArrayList();
                            strings.add(propCapitanRole.getName());
                            strings.add(propRole.getName());
                            STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191265, 0, strings);
                            SceneManager.sendAll(ssmn);
                            return true;
                        }
                    }
                } else {
                    return false;
                }
            }
        }
    }
}
