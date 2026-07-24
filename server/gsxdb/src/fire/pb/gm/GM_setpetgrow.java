//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.pet.PAddPetGrowProc;
import fire.pb.scene.Scene;
import xbean.Properties;

public class GM_setpetgrow extends GMCommand {
    boolean exec(String[] var1) {
        if (var1.length < 1) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            int var2 = Integer.parseInt(var1[0]);
            if (var2 == 0) {
                this.sendToGM("参数格式错误:" + this.usage());
                return false;
            } else {
                Properties var3 = xtable.Properties.select(this.getGmroleid());
                if (var3.getFightpetkey() == -1) {
                    this.sendToGM("您还没有参战宠物，请先设置参战宠物");
                    return false;
                } else {
                    PAddPetGrowProc var4 = new PAddPetGrowProc(this.getGmroleid(), var3.getFightpetkey(), var2);
                    var4.submit();
                    Scene.LOG.info("GM 给参战宠物修改成长。角色： " + this.getGmroleid() + "；参战宠物成长为 ：" + var2);
                    return true;
                }
            }
        }
    }

    String usage() {
        return "//setpetgrow 修改的成长值";
    }
}
