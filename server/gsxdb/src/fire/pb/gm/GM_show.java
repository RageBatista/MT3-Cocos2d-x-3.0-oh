//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import xtable.Roleid2userid;

public class GM_show extends GMCommand {
    boolean exec(String[] var1) {
        long var2 = this.getGmroleid();
        int var4 = Roleid2userid.select(var2);
        this.sendToGM("" + var4);
        return true;
    }

    String usage() {
        return null;
    }
}
