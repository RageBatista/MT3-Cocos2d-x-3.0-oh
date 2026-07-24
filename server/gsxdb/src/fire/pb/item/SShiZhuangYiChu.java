//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SShiZhuangYiChu implements ConvMain.Checkable, Comparable<SShiZhuangYiChu> {
    public int id = 0;
    public int moxing = 0;
    public int cailiao = 0;
    public int cailiaonum = 0;
    public int buff = 0;

    public int compareTo(SShiZhuangYiChu o) {
        return this.id - o.id;
    }

    public SShiZhuangYiChu() {
    }

    public SShiZhuangYiChu(SShiZhuangYiChu arg) {
        this.id = arg.id;
        this.moxing = arg.moxing;
        this.cailiao = arg.cailiao;
        this.cailiaonum = arg.cailiaonum;
        this.buff = arg.buff;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getmoxing() {
        return this.moxing;
    }

    public void setmoxing(int v) {
        this.moxing = v;
    }

    public int getcailiao() {
        return this.cailiao;
    }

    public void setcailiao(int v) {
        this.cailiao = v;
    }

    public int getcailiaonum() {
        return this.cailiaonum;
    }

    public void setcailiaonum(int v) {
        this.cailiaonum = v;
    }

    public int getbuff() {
        return this.buff;
    }

    public void setbuff(int v) {
        this.buff = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
