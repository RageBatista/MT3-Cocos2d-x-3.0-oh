//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PAddExpProc;
import fire.pb.PropRole;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.map.Npc;
import fire.pb.map.SceneManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import fire.pb.util.MessageUtil;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.WheelInfo;
import xbean.WheelInfos;
import xbean.WheelItem;
import xtable.Wheelprogress;

public class PFinishFortuneWheel extends Procedure {
    private final long roleid;
    private final long npckey;
    private final int serviceid;
    private final int suc;

    public PFinishFortuneWheel(long roleid, long npckey, int serviceid, int succ) {
        this.roleid = roleid;
        this.npckey = npckey;
        this.serviceid = serviceid;
        this.suc = succ;
    }

    protected boolean process() throws Exception {
        WheelInfos wts = Wheelprogress.get(this.roleid);
        if (null == wts) {
            return false;
        } else {
            Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
            WheelInfo wt = PReqFortuneWheel.findWheelType(wts, npc != null ? npc.getNpcID() : 0, this.serviceid);
            if (null == wt) {
                return false;
            } else {
                WheelItem item = (WheelItem)wt.getWheelitems().get(wt.getIndex());
                if (item == null) {
                    return false;
                } else {
                    int itemType = item.getItemtype();
                    boolean succ = false;
                    switch (itemType) {
                        case 1:
                            int rt = 0;
                            if (item.getBind() == 0) {
                                rt = BagUtil.addItem(this.roleid, item.getItemid(), item.getNum(), "award of Fortune Wheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, 4);
                            } else {
                                rt = BagUtil.addBindItem(this.roleid, item.getItemid(), item.getNum(), "award of Fortune Wheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, 4, false);
                            }

                            if (rt != item.getNum()) {
                                return false;
                            }

                            succ = true;
                            this.sendItemMsg(item.getItemid(), rt);
                            if (item.getMsgid() > 0) {
                                List<String> paras = new ArrayList();
                                paras.add((new PropRole(this.roleid, true)).getName());
                                paras.addAll(MessageUtil.getItemMsgParas(item.getItemid(), item.getNum()));
                                SceneManager.sendAll(MessageMgr.getMsgNotify(item.getMsgid(), 0, paras));
                            }
                            break;
                        case 2:
                            int baseExp = wt.getBaseexp();
                            int exp = baseExp;
                            if (this.suc == 1) {
                                if (item.getTimes() > 0) {
                                    exp = baseExp * item.getTimes() / 10;
                                } else if (item.getNum() > 0) {
                                    exp = item.getNum();
                                }
                            }

                            if (exp > baseExp) {
                                succ = (new PAddExpProc(this.roleid, (long)(exp - baseExp), false, 4003, "幸运大转盘")).call();
                            } else {
                                succ = true;
                            }

                            if (succ) {
                                this.sendExpMsg(exp - baseExp);
                            }
                            break;
                        case 3:
                            int baseMoney = wt.getBasemoney();
                            long money = (long)baseMoney;
                            if (this.suc == 1) {
                                if (item.getTimes() > 0) {
                                    money = (long)(baseMoney * item.getTimes() / 10);
                                } else if (item.getNum() > 0) {
                                    money = (long)item.getNum();
                                }
                            }

                            if (money > (long)baseMoney) {
                                Pack bag = new Pack(this.roleid, false);
                                long before = bag.getMoney();
                                bag.addSysMoney(money - (long)baseMoney, "award of Fortune Wheel", YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
                                succ = bag.getMoney() != before;
                            } else {
                                succ = true;
                            }

                            if (succ) {
                                this.sendMoneyMsg(money);
                            }
                            break;
                        case 4:
                            int baseSMoney = wt.getBasesmoney();
                            long smoney = (long)baseSMoney;
                            if (this.suc == 1) {
                                if (item.getTimes() > 0) {
                                    smoney = (long)(baseSMoney * item.getTimes() / 10);
                                } else if (item.getNum() > 0) {
                                    smoney = (long)item.getNum();
                                }
                            }

                            succ = true;
                    }

                    if (succ) {
                        if (wts.getWheellist().contains(wt)) {
                            wts.getWheellist().remove(wt);
                            if (wts.getWheellist().isEmpty()) {
                                Wheelprogress.remove(this.roleid);
                            }

                            return true;
                        } else {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
            }
        }
    }

    private void sendMoneyMsg(long money) {
        Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
        int npcid = 0;
        if (npc != null) {
            npcid = npc.getNpcID();
        }

        List<String> paras = new ArrayList();
        paras.add(Long.toString(money));
        psendWhileCommit(this.roleid, MessageMgr.getMsgNotify(MessageMgr.ADD_MONEY, npcid, paras));
    }

    private void sendExpMsg(int exp) {
        Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
        int npcid = 0;
        if (npc != null) {
            npcid = npc.getNpcID();
        }

        List<String> paras = new ArrayList();
        paras.add(Integer.toString(exp));
        psendWhileCommit(this.roleid, MessageMgr.getMsgNotify(MessageMgr.ADD_EXP, npcid, paras));
    }

    private void sendItemMsg(int itemid, int num) {
        Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
        int npcid = 0;
        if (npc != null) {
            npcid = npc.getNpcID();
        }

        ItemShuXing attr = Module.getInstance().getItemManager().getAttr(itemid);
        if (attr != null) {
            String name = attr.getName();
            String unit = attr.getUnit();
            List<String> paras = MessageUtil.getMsgParaList(new String[]{Integer.toString(num), unit, name});
            psendWhileCommit(this.roleid, MessageMgr.getMsgNotify(MessageMgr.ADD_ITEM, npcid, paras));
        }
    }
}
