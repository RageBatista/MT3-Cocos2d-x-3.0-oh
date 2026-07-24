//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.pet.PPetFull;
import xbean.Properties;

public class GM_setpetfull extends GMCommand {
    boolean exec(String[] var1) {
        Properties var2 = xtable.Properties.select(this.getGmroleid());
        if (var2.getFightpetkey() == -1) {
            this.sendToGM("您还没有参战宠物，请先设置参战宠物");
            return false;
        } else {
            PPetFull var3 = new PPetFull(this.getGmroleid(), var2.getFightpetkey());
            var3.submit();
            return true;
        }
    }

    String usage() {
        return "//setpetfull";
    }
}
