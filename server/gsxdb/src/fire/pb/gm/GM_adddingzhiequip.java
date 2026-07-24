//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.AddItemResult;
import fire.pb.item.EquipDoubleInfo;
import fire.pb.item.EquipItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.item.NewShuangJiaInfo;
import fire.pb.item.SGetItemTips;
import fire.pb.main.ModuleManager;
import java.util.HashMap;
import mkdb.Procedure;

public class GM_adddingzhiequip extends GMCommand {
    public boolean exec(String[] paramArrayOfString) {
        if (paramArrayOfString.length < 3) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            final int id = Integer.parseInt(paramArrayOfString[0]);
            final int skillid = Integer.parseInt(paramArrayOfString[1]);
            final int effectid = Integer.parseInt(paramArrayOfString[2]);
            final int equipmentsid = Integer.parseInt(paramArrayOfString[3]);
            final String baseattr = paramArrayOfString[4];
            final String shuiangjia = paramArrayOfString[5];
            final String ronglian = paramArrayOfString[6];
            final Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
            if (itemmodule != null) {
                (new Procedure() {
                    protected boolean process() {
                        ItemBase itemBase = itemmodule.getItemManager().genItemBase(id, 1);
                        if (!(itemBase instanceof EquipItem)) {
                            GM_adddingzhiequip.this.sendToGM("参数格式错误：物品不是装备" + GM_adddingzhiequip.this.usage());
                            return false;
                        } else {
                            EquipItem equipItem = (EquipItem)itemBase;
                            if (effectid / 10000 != 42 && effectid / 10000 != 43) {
                                GM_adddingzhiequip.this.sendToGM("参数格式错误：特效代码错误" + GM_adddingzhiequip.this.usage());
                                return false;
                            } else {
                                equipItem.getExtInfo().setSkill(effectid);
                                if (skillid / 10000 != 42 && skillid / 10000 != 43) {
                                    GM_adddingzhiequip.this.sendToGM("参数格式错误：特技代码错误" + GM_adddingzhiequip.this.usage());
                                    return false;
                                } else {
                                    equipItem.getExtInfo().setEffect(skillid);
                                    if (equipmentsid > 0) {
                                        equipItem.getExtInfo().setEquipsit(equipmentsid);
                                        System.out.println("定制套装id:" + equipmentsid);
                                    }

                                    if (baseattr != "") {
                                        String[] data = baseattr.split(",");
                                        equipItem.getEquipAttr().getAttr().clear();

                                        for(String attr : data) {
                                            String[] props = attr.split("=");
                                            equipItem.getEquipAttr().getAttr().put(Integer.valueOf(props[0]), Integer.valueOf(props[1]));
                                        }
                                    }

                                    if (shuiangjia != "") {
                                        String[] data = shuiangjia.split(",");
                                        equipItem.getEquipAttr().getAddattr().clear();

                                        for(String attr : data) {
                                            String[] props = attr.split("=");
                                            equipItem.getEquipAttr().getAddattr().put(Integer.valueOf(props[0]), Integer.valueOf(props[1]));
                                        }
                                    }

                                    NewShuangJiaInfo shuangJiaInfo = new NewShuangJiaInfo();
                                    HashMap<Long, NewShuangJiaInfo> map = EquipDoubleInfo.getEquipAllInfo(GM_adddingzhiequip.this.getGmroleid());
                                    if (map == null) {
                                        map = new HashMap();
                                    }

                                    if (ronglian != "") {
                                        String[] data = ronglian.split(",");
                                        equipItem.getEquipAttr().getExtraattr().clear();
                                        int i = 0;

                                        for(String attr : data) {
                                            String[] props = attr.split("=");
                                            if (i < 2) {
                                                shuangJiaInfo.doubleadd.put(Integer.valueOf(props[0]), Integer.valueOf(props[1]));
                                            } else {
                                                equipItem.getEquipAttr().getExtraattr().put(Integer.valueOf(props[0]), Integer.valueOf(props[1]));
                                            }

                                            ++i;
                                        }
                                    }

                                    ItemMaps itemMaps = itemmodule.getItemMaps(GM_adddingzhiequip.this.getGmroleid(), 1, false);
                                    boolean added = itemMaps.doAddItem(equipItem, -1, "gm", YYLoggerTuJingEnum.GM, 0) == AddItemResult.SUCC;
                                    map.put(equipItem.getUniqId(), shuangJiaInfo);
                                    EquipDoubleInfo.UpdateEquipInfo(GM_adddingzhiequip.this.getGmroleid(), map);
                                    Octets octets = equipItem.getTips();
                                    SGetItemTips sGetItemTips = new SGetItemTips(1, equipItem.getKey(), octets);
                                    Procedure.psendWhileCommit(GM_adddingzhiequip.this.getGmroleid(), sGetItemTips);
                                    return added;
                                }
                            }
                        }
                    }
                }).submit();
                return true;
            } else {
                return true;
            }
        }
    }

    public String usage() {
        return "//addsequip skillid effectid baseattr shuangjia ronglian";
    }
}
