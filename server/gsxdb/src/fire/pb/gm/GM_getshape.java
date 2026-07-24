//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.PropRole;

public class GM_getshape extends GMCommand {
    boolean exec(String[] var1) {
        PropRole var2 = new PropRole(this.getGmroleid(), true);
        int var3 = var2.getShape();
        this.sendToGM("" + var3);
        return true;
    }

    String usage() {
        return null;
    }
}
