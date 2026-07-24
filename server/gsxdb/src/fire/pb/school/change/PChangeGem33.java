//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.Module;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.SEquipHeCheng;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PChangeGem33 extends Procedure {
    static Map<Integer, SEquipHeCheng> produceConfs = ConfigManager.getInstance().getConf(SEquipHeCheng.class);
    private final long roleId;
    private final int gemKey;
    private final int newGemItemId;

    public PChangeGem33(long roleId, int gemKey, int newGemItemId) {
        this.roleId = roleId;
        this.gemKey = gemKey;
        this.newGemItemId = newGemItemId;
    }

    protected boolean process() throws Exception {
        if (Module.existState(this.roleId, 507004)) {
            MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
            return false;
        } else {
            Pack bag = new Pack(this.roleId, false);
            ItemBase item = bag.getItem(this.gemKey);
            int oldItemAttr = item.getItemId();

            for(ItemBase bi : bag) {
                if (bi.getItemId() == oldItemAttr && bi.isBind()) {
                    MessageMgr.sendMsgNotify(this.roleId, 198006, (List)null);
                    return false;
                }
            }

            int remainNum = bag.getBagItemNum(item.getItemId());
            if (remainNum < 2) {
                MessageMgr.sendMsgNotify(this.roleId, 150167, (List)null);
                return false;
            } else {
                if (produceConfs != null) {
                    for(SEquipHeCheng pc : produceConfs.values()) {
                        if (pc != null && this.newGemItemId == pc.getNextid()) {
                            bag.removeItemById(this.gemKey, 2, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.removeItemWithKey(this.gemKey, 2, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.addItem(this.newGemItemId, 1, "Treasuremap used success", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, false);
                            MessageMgr.sendMsgNotify(this.roleId, 194080, (List)null);
                            break;
                        }
                    }
                }

                SChangeGem33 sendResult = new SChangeGem33();
                psendWhileCommit(this.roleId, sendResult);
                return true;
            }
        }
    }
}
