//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.PropConf.FuShi;
import fire.pb.fushi.Module;
import fire.pb.item.Pack;
import fire.pb.map.Npc;
import fire.pb.map.SceneManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.util.BagUtil;
import fire.pb.util.MessageUtil;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;

public class PTenTimesHappy extends Procedure {
    private final long roleid;
    private final int boxtype;
    private final long npckey;

    public PTenTimesHappy(long roleid, int boxtype, long npckey) {
        this.roleid = roleid;
        this.boxtype = boxtype;
        this.npckey = npckey;
    }

    protected boolean process() throws Exception {
        ArrayList<Integer> items = new ArrayList();
        ArrayList<String> notice = new ArrayList();
        PropRole pRole = new PropRole(this.roleid, true);
        notice.add(pRole.getName());
        Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
        if (npc == null) {
            MessageMgr.psendMsgNotifyWhileRollback(this.roleid, 170021, (List)null);
            return false;
        } else {
            for(int i = 0; i < 10; ++i) {
                int itemIndex = GameManager.getInstance().getAwardItemIndex(this.boxtype);
                items.add(itemIndex);
            }

            Pack bag = new Pack(this.roleid, false);
            if (this.boxtype == 3) {
                int bagItemNum = bag.getBagItemNum(337942);
                if (bagItemNum < 10) {
                    return false;
                }
            }

            if (this.boxtype == 2) {
                int bagItemNum = bag.getBagItemNum(337943);
                if (bagItemNum < 10) {
                    return false;
                }
            }

            switch (this.boxtype) {
                case 2:
                    Pack bag1 = new Pack(this.roleid, false);
                    long ret = (long)bag1.removeItemById(337943, 10, YYLoggerTuJingEnum.tujing_Value_shenmishangren, 337943, "TraderWheel");
                    if (ret == 0L) {
                        return false;
                    }
                    break;
                case 3:
                    Pack bag2 = new Pack(this.roleid, false);
                    long ret2 = (long)bag2.removeItemById(337942, 10, YYLoggerTuJingEnum.tujing_Value_shenmixiaofan, 337942, "TraderWheel");
                    if (ret2 == 0L) {
                        return false;
                    }
                    break;
                case 4:
                    Pack bag3 = new Pack(this.roleid, false);
                    long ret3 = (long)bag3.removeItemById(339127, 10, YYLoggerTuJingEnum.tujing_Value_shenmishangren, 339127, "TraderWheel");
                    if (ret3 == 0L) {
                        return false;
                    }
                    break;
                case 5:
                    Pack bag4 = new Pack(this.roleid, false);
                    long ret4 = (long)bag4.removeItemById(339128, 10, YYLoggerTuJingEnum.tujing_Value_shenmishangren, 339128, "TraderWheel");
                    if (ret4 == 0L) {
                        return false;
                    }
                    break;
                case 6:
                    Pack bag5 = new Pack(this.roleid, false);
                    long ret5 = (long)bag5.removeItemById(339129, 10, YYLoggerTuJingEnum.tujing_Value_shenmishangren, 339129, "TraderWheel");
                    if (ret5 == 0L) {
                        return false;
                    }
            }

            for(Integer item : items) {
                WheelAwardItem awardItem = GameManager.getInstance().getAwardItem(this.boxtype, item);
                notice.addAll(MessageUtil.getItemMsgParas(awardItem.itemid, awardItem.itemnum));
                if (awardItem == null) {
                    return false;
                }

                int realAdd = BagUtil.addItem(this.roleid, awardItem.itemid, awardItem.itemnum, "TraderWheel", YYLoggerTuJingEnum.tujing_Value_zhuanpan, awardItem.itemid);
                if (realAdd == awardItem.itemnum && awardItem.msg == 1) {
                    MessageUtil.psendAddItemWhileCommit(this.roleid, awardItem.itemid, realAdd);
                }

                int mustAdd = 0;
                if (awardItem.mustitem > 0) {
                    mustAdd = BagUtil.addItem(this.roleid, awardItem.mustitem, awardItem.mustnum, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, awardItem.mustitem);
                }

                if (mustAdd > 0 && mustAdd == awardItem.mustnum) {
                    MessageUtil.psendAddItemWhileCommit(this.roleid, awardItem.mustitem, mustAdd);
                }

                if (awardItem.itemid == FuShi.GOLD_BOX_ID) {
                    Pack bag2 = new Pack(this.roleid, false);
                    bag2.addSysCurrency((long)((float)FuShi.GOLD_BOX_NUM * Module.getCreditPointValue(10)), 13, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, 0);
                }

                if (awardItem.itemid == FuShi.SILVER_BOX_ID) {
                    Pack bag2 = new Pack(this.roleid, false);
                    bag2.addSysCurrency((long)((float)FuShi.SILVER_BOX_NUM * Module.getCreditPointValue(11)), 13, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, 0);
                }
            }

            if (this.boxtype == 2) {
                notice.add("金宝箱");
            }

            if (this.boxtype == 3) {
                notice.add("银宝箱");
            }

            STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(196666, 0, notice);
            SceneManager.sendAll(ssmn);
            return true;
        }
    }
}
