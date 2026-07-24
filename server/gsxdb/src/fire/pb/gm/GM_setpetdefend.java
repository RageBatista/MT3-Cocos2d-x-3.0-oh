//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.pet.PPetDefend;
import xbean.Properties;

public class GM_setpetdefend extends GMCommand {
    boolean exec(String[] var1) {
        if (var1.length < 1) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            int var2 = Integer.parseInt(var1[0]);
            if (var2 <= 500) {
                this.sendToGM("参数格式错误:" + this.usage());
                return false;
            } else {
                Properties var3 = xtable.Properties.select(this.getGmroleid());
                if (var3.getFightpetkey() == -1) {
                    this.sendToGM("您还没有参战宠物，请先设置参战宠物");
                    return false;
                } else {
                    PPetDefend var4 = new PPetDefend(this.getGmroleid(), var3.getFightpetkey(), var2);
                    var4.submit();
                    return true;
                }
            }
        }
    }

    String usage() {
        return "//setpetAttack 宠物防御资质";
    }
}
