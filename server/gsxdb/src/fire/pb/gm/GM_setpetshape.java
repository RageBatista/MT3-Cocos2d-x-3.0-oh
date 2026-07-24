//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.StateCommon;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.pet.SRefreshPetInfo;
import mkdb.Procedure;
import xbean.PetInfo;
import xbean.Properties;

public class GM_setpetshape extends GMCommand {
    public GM_setpetshape() {
    }

    public boolean exec(String[] args) {
        if (args.length < 1) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            final int shape = Integer.parseInt(args[0]);
            if (shape == 0) {
                this.sendToGM("参数格式错误:" + this.usage());
                return false;
            } else {
                final long roleid;
                if (args.length >= 2) {
                    roleid = Long.valueOf(args[1]);
                } else {
                    roleid = this.getGmroleid();
                }

                if (!StateCommon.isOnline(roleid)) {
                    return false;
                } else {
                    final Properties prop = xtable.Properties.select(roleid);
                    (new Procedure() {
                        protected boolean process() {
                            if (prop.getFightpetkey() == -1) {
                                GM_setpetshape.this.sendToGM("您还没有参战宠物，请先设置参战宠物");
                                return false;
                            } else {
                                PetColumn petColumn = new PetColumn(roleid, 1, false);
                                Pet pet = petColumn.getPet(prop.getFightpetkey());
                                if (pet == null) {
                                    GMCommand.logger.info("角色id " + roleid + "染色的宠物不存在" + "\t数据错误");
                                    return false;
                                } else {
                                    PetInfo petInfo = petColumn.getPetInfo(prop.getFightpetkey());
                                    if (petInfo.getPetid() <= 0) {
                                        petInfo.setPetid(petInfo.getId());
                                    }

                                    petInfo.setId(shape);
                                    SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                                    psendWhileCommit(roleid, refresh);
                                    return true;
                                }
                            }
                        }
                    }).submit();
                    return true;
                }
            }
        }
    }

    public String usage() {
        return "//setpetshape shapeid";
    }
}
