//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class Szuoqicolour implements ConvMain.Checkable, Comparable<Szuoqicolour> {
    public int id = 0;
    public String yanse = null;
    public int itemcode = 0;
    public int itemnum = 0;

    public int compareTo(Szuoqicolour var1) {
        return this.id - var1.id;
    }

    public Szuoqicolour() {
    }

    public Szuoqicolour(Szuoqicolour var1) {
        this.id = var1.id;
        this.yanse = var1.yanse;
        this.itemcode = var1.itemcode;
        this.itemnum = var1.itemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> var1) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public String getYanse() {
        return this.yanse;
    }

    public void setYanse(String var1) {
        this.yanse = var1;
    }

    public int getItemcode() {
        return this.itemcode;
    }

    public void setItemcode(int var1) {
        this.itemcode = var1;
    }

    public int getItemnum() {
        return this.itemnum;
    }

    public void setItemnum(int var1) {
        this.itemnum = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
