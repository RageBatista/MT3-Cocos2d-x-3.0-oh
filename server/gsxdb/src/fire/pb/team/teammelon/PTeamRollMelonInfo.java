//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.activity.award.RewardMgr;
import fire.pb.circletask.UpdateCircleTaskState;
import fire.pb.item.AddItemResult;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.map.SceneManager;
import fire.pb.mission.instance.line.LineInstManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.util.MessageUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.ETeamMelon;
import xbean.Item;
import xbean.Pod;
import xbean.TeamMelon;
import xtable.Battlemelonid2melon;
import xtable.Locks;
import xtable.Properties;
import xtable.Roleid2battlemelonid;

public class PTeamRollMelonInfo extends Procedure {
    private final long battlemelonid;
    private final int end;

    public PTeamRollMelonInfo(long battlemelonid, int end) {
        this.battlemelonid = battlemelonid;
        this.end = end;
    }

    protected boolean process() throws Exception {
        ETeamMelon eteammelon = Battlemelonid2melon.get(this.battlemelonid);
        if (eteammelon == null) {
            return true;
        } else {
            ArrayList<Long> roleids = new ArrayList();

            for(Long e : eteammelon.getMelonerlist()) {
                roleids.add(e);
            }

            this.lock(Locks.ROLELOCK, roleids);

            for(Map.Entry<Long, TeamMelon> e : eteammelon.getMelonid2melons().entrySet()) {
                STeamRollMelonInfo msg = new STeamRollMelonInfo();
                msg.melonid = (Long)e.getKey();
                TeamMelon teammelon = (TeamMelon)e.getValue();
                if (this.end != 0 || teammelon.getOpnum() >= teammelon.getMelonroleids().size()) {
                    RewardMgr.MsgInfos msgInfos = RewardMgr.getInstance().getMsgInfos(teammelon.getAwardid());
                    int max = 0;
                    long grab = 0L;

                    for(Map.Entry<Long, Integer> e1 : teammelon.getMelonroleids().entrySet()) {
                        RoleRollInfo roleinfo = new RoleRollInfo();
                        roleinfo.roleid = (Long)e1.getKey();
                        roleinfo.roll = (Integer)e1.getValue();
                        roleinfo.rolename = Properties.selectRolename((Long)e1.getKey());
                        msg.rollinfolist.add(roleinfo);
                        if ((Integer)e1.getValue() > max) {
                            max = (Integer)e1.getValue();
                            grab = (Long)e1.getKey();
                        }

                        if (this.end == 1) {
                            Integer alreadroll = (Integer)teammelon.getOpmelonroleids().get(e1.getKey());
                            if (alreadroll == null) {
                                xbean.Properties roleprop = Properties.select(roleinfo.roleid);
                                SOneTeamRollMelonInfo msg1 = new SOneTeamRollMelonInfo();
                                msg1.itemid = teammelon.getItemid();
                                msg1.melonid = (Long)e.getKey();
                                msg1.rollinfo.roleid = roleinfo.roleid;
                                msg1.rollinfo.rolename = roleprop.getRolename();
                                msg1.rollinfo.roll = roleinfo.roll;

                                for(Long roleid2 : eteammelon.getMelonerlist()) {
                                    Procedure.psendWhileCommit(roleid2, msg1);
                                }

                                for(Long roleid2 : eteammelon.getWatchmelonerlist()) {
                                    if (roleid2 != null) {
                                        Procedure.psendWhileCommit(roleid2, msg1);
                                    }
                                }
                            }
                        }
                    }

                    if (grab != 0L) {
                        Item rollitem1 = teammelon.getItemdata();
                        Item rollitem2 = Pod.newItem();
                        this.CopyItemData(rollitem2, rollitem1);
                        ItemBase item = Module.getInstance().getItemManager().toItemBase(rollitem2, 0L, 0, 0);
                        Pack bag = (Pack)Module.getInstance().getItemMaps(grab, 1, false);
                        int bagid = bag.getPackid();
                        int itemkey = item.getKey();
                        if (bag.isFull()) {
                            ItemMaps tempBag = Module.getInstance().getItemMaps(grab, 4, false);
                            if (tempBag.doAddItem(item, -1, "Roll点", YYLoggerTuJingEnum.tujing_Value_battle, 2) == AddItemResult.SUCC) {
                                this.sendAwardMsg(grab, item.getItemId(), rollitem1.getNumber(), msgInfos);
                                MessageUtil.psendAddItemWhileCommit(grab, item.getItemId(), rollitem1.getNumber());
                            }
                        } else if (bag.doAddItem(item, -1, "Roll点", YYLoggerTuJingEnum.tujing_Value_battle, 2) == AddItemResult.SUCC) {
                            this.sendAwardMsg(grab, item.getItemId(), rollitem1.getNumber(), msgInfos);
                            MessageUtil.psendAddItemWhileCommit(grab, item.getItemId(), rollitem1.getNumber());
                        }

                        itemkey = item.getKey();
                        MelonItemBagInfo melonitem = new MelonItemBagInfo();
                        melonitem.bagid = bagid;
                        melonitem.itemkey = itemkey;
                        msg.melonitemlist.add(melonitem);
                    }

                    msg.grabroleid = grab;
                    if (msg.grabroleid != 0L) {
                        msg.grabrolename = Properties.selectRolename(grab);
                    }

                    for(Long roleid : roleids) {
                        Procedure.psendWhileCommit(roleid, msg);
                    }

                    for(Long roleid : eteammelon.getWatchmelonerlist()) {
                        if (roleid != null) {
                            Procedure.psendWhileCommit(roleid, msg);
                        }
                    }

                    if (this.end == 0) {
                        eteammelon.getMelonid2melons().remove(e.getKey());
                        if (eteammelon.getMelonid2melons().isEmpty()) {
                            for(Long roleid : roleids) {
                                Roleid2battlemelonid.remove(roleid);
                            }

                            Battlemelonid2melon.remove(this.battlemelonid);
                            if (eteammelon.getMelontype() == 1) {
                                pexecuteWhileCommit(new UpdateCircleTaskState(eteammelon.getDataid2(), eteammelon.getDataid(), 3));
                            } else if (eteammelon.getMelontype() == 2) {
                                LineInstManager.getInstance().doNextStep(eteammelon.getDataid(), eteammelon.getDataid2());
                            }
                        }

                        return true;
                    }
                }
            }

            if (this.end == 1) {
                for(Long roleid : roleids) {
                    Roleid2battlemelonid.remove(roleid);
                }

                Battlemelonid2melon.remove(this.battlemelonid);
                if (eteammelon.getMelontype() == 1) {
                    pexecuteWhileCommit(new UpdateCircleTaskState(eteammelon.getDataid2(), eteammelon.getDataid(), 3));
                } else if (eteammelon.getMelontype() == 2) {
                    LineInstManager.getInstance().doNextStep(eteammelon.getDataid(), eteammelon.getDataid2());
                }
            }

            return true;
        }
    }

    public void CopyItemData(Item out, Item in) {
        out.setExtid(in.getExtid());
        out.setFlags(in.getFlags());
        out.setId(in.getId());
        out.setLoseeffecttime(in.getLoseeffecttime());
        out.setNumber(in.getNumber());
        out.setPosition(in.getPosition());
        out.setTimeout(in.getTimeout());
        out.setUniqueid(in.getUniqueid());
        out.getNumbermap().putAll(in.getNumbermap());
    }

    private void sendAwardMsg(long roleid, int itemID, int itemNum, RewardMgr.MsgInfos msgInfos) {
        if (msgInfos != null) {
            if (itemNum > 0) {
                ItemShuXing attr = Module.getInstance().getItemManager().getAttr(itemID);
                if (attr != null) {
                    if (msgInfos.getMsgid() > 0 && attr.rare == 1) {
                        List<String> paras = new ArrayList();
                        PropRole pRole = new PropRole(roleid, true);
                        paras.add(pRole.getName());
                        paras.addAll(MessageUtil.getItemMsgParas(itemID, itemNum));
                        STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(msgInfos.getMsgid(), 0, paras);
                        SceneManager.sendAll(ssmn);
                    }

                }
            }
        }
    }
}
