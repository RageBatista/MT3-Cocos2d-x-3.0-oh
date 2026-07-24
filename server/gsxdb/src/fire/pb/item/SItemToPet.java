//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SItemToPet implements ConvMain.Checkable, Comparable<SItemToPet> {
    public int id = 0;
    public int petId = 0;
    public int bagType = 0;

    public int compareTo(SItemToPet o) {
        return this.id - o.id;
    }

    public SItemToPet() {
    }

    public SItemToPet(SItemToPet arg) {
        this.id = arg.id;
        this.petId = arg.petId;
        this.bagType = arg.bagType;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getPetId() {
        return this.petId;
    }

    public void setPetId(int v) {
        this.petId = v;
    }

    public int getBagType() {
        return this.bagType;
    }

    public void setBagType(int v) {
        this.bagType = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
