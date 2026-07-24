//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.EquipItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.main.ModuleManager;
import java.util.ArrayList;
import mkdb.Procedure;

public class GM_addsitequip extends GMCommand {
    public boolean exec(String[] args) {
        if (args.length < 2) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            final int sitid = Integer.parseInt(args[0]);
            final int effectid = Integer.parseInt(args[1]);
            final Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
            if (itemmodule != null) {
                (new Procedure() {
                    protected boolean process() {
                        ArrayList<Integer> list = new ArrayList();
                        list.add(9120101);
                        list.add(9120102);
                        list.add(9120103);
                        list.add(9120104);
                        list.add(9120105);
                        list.add(9120106);
                        list.add(9120107);
                        list.add(9120108);
                        list.add(9120109);
                        list.add(9120110);
                        list.add(9120111);
                        list.add(9120207);
                        list.add(9120208);
                        list.add(9120309);
                        list.add(9120310);
                        list.add(9120411);
                        list.add(9120512);
                        list.add(9120613);

                        for(Integer integer : list) {
                            ItemBase item = itemmodule.getItemManager().genItemBase(integer, 1);
                            if (!(item instanceof EquipItem)) {
                                GM_addsitequip.this.sendToGM("参数格式错误：物品不是装备." + GM_addsitequip.this.usage());
                                return false;
                            }

                            EquipItem equip = (EquipItem)item;
                            if (sitid > 0) {
                                equip.getExtInfo().setSkill(sitid);
                            }

                            if (effectid > 0) {
                                equip.getExtInfo().setEffect(effectid);
                            }

                            if (sitid > 0) {
                                equip.getExtInfo().setNewskill(sitid);
                            }

                            if (effectid > 0) {
                                equip.getExtInfo().setNeweffect(effectid);
                            }

                            ItemMaps bag = itemmodule.getItemMaps(GM_addsitequip.this.getGmroleid(), 1, false);
                            bag.doAddItem(equip, -1, "gm", YYLoggerTuJingEnum.GM, 0);
                        }

                        return true;
                    }
                }).submit();
            }

            return true;
        }
    }

    public String usage() {
        return "添加带有特技的装备";
    }
}
