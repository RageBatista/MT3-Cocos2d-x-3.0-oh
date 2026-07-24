//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.MessageUtil;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.Properties;

public class PPetEquipFenJie extends Procedure {
    private long roleId;
    private int keyinpack;

    public PPetEquipFenJie(long roleid, int keyinpack) {
        this.roleId = roleid;
        this.keyinpack = keyinpack;
    }

    public boolean process() {
        Pack bag = new Pack(this.roleId, false);
        ItemBase item = bag.getItem(this.keyinpack);
        if (!(item instanceof PetEquipItem)) {
            return false;
        } else {
            Map<Integer, PetEquipItemShuXing> mapConfig = ConfigManager.getInstance().getConf(PetEquipItemShuXing.class);
            PetEquipItemShuXing petEquipItemShuXing = (PetEquipItemShuXing)mapConfig.get(item.getItemId());
            String skill = petEquipItemShuXing.getSkill();
            String[] split = skill.split(";");
            if (split.length < 2) {
                return false;
            } else if (bag.removeItemWithKey(this.keyinpack, 1, YYLoggerTuJingEnum.tujing_Value_fenjieget, this.keyinpack, "宠物装备分解") != 1) {
                return false;
            } else if (bag.addItem(Integer.valueOf(split[0]), Integer.valueOf(split[1]), "分解奖励", YYLoggerTuJingEnum.tujing_Value_fenjieget, Integer.valueOf(split[0]), true) != Integer.valueOf(split[1])) {
                return false;
            } else {
                Properties prop = xtable.Properties.get(this.roleId);
                if (prop == null) {
                    return false;
                } else {
                    String name = prop.getRolename();
                    List<String> stringList = MessageMgr.getStringList(new Object[]{name, petEquipItemShuXing.getName()});
                    stringList.addAll(MessageUtil.getItemMsgParas(Integer.valueOf(split[0]), Integer.valueOf(split[1])));
                    MessageMgr.psendMsgNotify(this.roleId, 191234, stringList);
                    return true;
                }
            }
        }
    }
}
