//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.main.ModuleManager;
import fire.pb.util.BagUtil;
import mkdb.Procedure;

public class GM_addcomitem extends GMCommand {
    boolean exec(String[] args) {
        if (args[0].matches("\\d+L")) {
            Long uid = Long.parseLong(args[0].substring(0, args[0].length() - 1));
            Procedure.execute(new PRecycleItem(this.getGmroleid(), uid), new Procedure.Done<PRecycleItem>() {
                public void doDone(PRecycleItem p) {
                    GM_addcomitem.this.sendToGM(p.getResult());
                }
            });
            return true;
        } else {
            Integer idmin;
            Integer idmax;
            if (args[0].matches("\\d+-\\d+")) {
                String[] ids = args[0].split("-");
                idmin = Integer.parseInt(ids[0]);
                idmax = Integer.parseInt(ids[1]);
            } else if (args[0].matches("\\d+")) {
                idmin = Integer.parseInt(args[0]);
                idmax = idmin;
            } else {
                idmin = this.getObjectIdByName(args[0]);
                idmax = idmin;
            }

            if (idmin == null) {
                return false;
            } else {
                Integer number;
                if (args.length >= 2) {
                    number = Integer.valueOf(args[1]);
                } else {
                    number = 1;
                }

                long roleid;
                if (args.length >= 3) {
                    roleid = Long.valueOf(args[2]);
                } else {
                    roleid = this.getGmroleid();
                }

                Integer bagid;
                if (args.length >= 4) {
                    if (args[3].matches("\\d+")) {
                        bagid = Integer.valueOf(args[3]);
                    } else if (args[3].equals("背包")) {
                        bagid = 1;
                    } else if (args[3].equals("仓库")) {
                        bagid = 2;
                    } else {
                        bagid = 1;
                    }
                } else {
                    bagid = 1;
                }

                Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
                if (itemmodule != null) {
                    for(int i = idmin; i <= idmax; ++i) {
                        (new PAddItem(roleid, itemmodule, i, number, bagid)).submit();
                    }
                }

                return true;
            }
        }
    }

    String usage() {
        return "addcomitem id number roleid,bagtype 后三个参数为可选";
    }

    private class PAddItem extends Procedure {
        private final Module itemmodule;
        private final int id;
        private final int number;
        private final int bagid;
        private final long roleid;

        PAddItem(long roleid, Module itemmodule, int id, int number, int bagid) {
            this.itemmodule = itemmodule;
            this.roleid = roleid;
            this.id = id;
            this.bagid = bagid;
            this.number = number;
        }

        protected boolean process() {
            ItemMaps ic = Module.getInstance().getItemMaps(this.roleid, this.bagid, false);
            boolean isSucc = false;
            if (ic == null) {
                isSucc = false;
            } else {
                isSucc = BagUtil.addItem(this.roleid, this.id, this.number, "GM添加物品", YYLoggerTuJingEnum.GM, this.id) > 0;
            }

            ItemShuXing itemAttr = this.itemmodule.getItemManager().getAttr(this.id);
            String name = "unknown name";
            if (itemAttr != null) {
                name = itemAttr.getName();
            }

            if (isSucc) {
                String info = "物品发送成功：" + name + "×" + this.number + " 已发送给角色" + this.roleid;
                GM_addcomitem.this.sendToGM(info);
            } else {
                GM_addcomitem.this.sendToGM("物品发送失败：" + name + "×" + this.number + " 发送给角色" + this.roleid + " 失败");
            }

            return isSucc;
        }
    }
}
