//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PAllGemHeCheng extends Procedure {
    private long roleId;
    private int gemKey;
    private int bagId;
    private int repairType;
    static Map<Integer, SEquipHeCheng> combineConfs = ConfigManager.getInstance().getConf(SEquipHeCheng.class);

    public PAllGemHeCheng(long roleId, int keyinpack, int packid, int repairtype) {
        this.roleId = roleId;
        this.gemKey = keyinpack;
        this.bagId = packid;
        this.repairType = repairtype;
    }

    public boolean process() {
        if (this.bagId != 1) {
            Module.logger.debug("背包类型不正确");
            return false;
        } else if (fire.pb.buff.Module.existState(this.roleId, 507004)) {
            return false;
        } else {
            ItemMaps itemMaps = Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
            ItemBase item = itemMaps.getItem(this.gemKey);
            if (!(item instanceof GemItem)) {
                MessageMgr.sendMsgNotify(this.roleId, 200184, (List)null);
                System.out.println("想要合成的物品不是宝石！");
                return false;
            } else {
                SEquipHeCheng sEquipHeCheng = (SEquipHeCheng)combineConfs.get(item.getItemId());
                if (sEquipHeCheng == null) {
                    MessageMgr.sendMsgNotify(this.roleId, 200185, (List)null);
                    System.out.println("当前宝石已经是最顶级了！");
                    return false;
                } else {
                    int nextid = sEquipHeCheng.getNextid();
                    if (nextid <= 0) {
                        MessageMgr.sendMsgNotify(this.roleId, 200185, (List)null);
                        System.out.println("当前宝石已经是最顶级了！");
                        return false;
                    } else {
                        int number = item.getNumber();
                        if (number < 2) {
                            MessageMgr.sendMsgNotify(this.roleId, 200183, (List)null);
                            return false;
                        } else {
                            int resultnum = number / 2;
                            if (itemMaps.removeItemWithKey(this.gemKey, resultnum * 2, YYLoggerTuJingEnum.tujing_Value_fenjie, item.getItemId(), "装备分解") != resultnum * 2) {
                                System.out.println("道具消耗错误");
                                return false;
                            } else if (itemMaps.doAddItem(nextid, resultnum, "宝石合成", YYLoggerTuJingEnum.tujing_Value_fenjieget, nextid) != resultnum) {
                                System.out.println("合成结果数量错误");
                                return false;
                            } else {
                                MessageMgr.sendMsgNotify(this.roleId, 200186, (List)null);
                                return true;
                            }
                        }
                    }
                }
            }
        }
    }
}
