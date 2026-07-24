//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.Map;
import mytools.ConvMain;

public class SMallShop implements ConvMain.Checkable, Comparable<SMallShop> {
    public int id = 0;
    public int type = 0;
    public int totalrecharge = 0;
    public int viplvrequire = 0;

    public int compareTo(SMallShop o) {
        return this.id - o.id;
    }

    public SMallShop() {
    }

    public SMallShop(SMallShop arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.totalrecharge = arg.totalrecharge;
        this.viplvrequire = arg.viplvrequire;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getTotalrecharge() {
        return this.totalrecharge;
    }

    public void setTotalrecharge(int v) {
        this.totalrecharge = v;
    }

    public int getViplvrequire() {
        return this.viplvrequire;
    }

    public void setViplvrequire(int v) {
        this.viplvrequire = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
