//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class FoodItemAttr extends RecoveryItemAttr {
    public int 是否有品质 = 0;
    public int 增加宠物寿命 = 0;

    public FoodItemAttr(RecoveryItemAttr arg) {
        super(arg);
    }

    public FoodItemAttr() {
    }

    public FoodItemAttr(FoodItemAttr arg) {
        super(arg);
        this.是否有品质 = arg.是否有品质;
        this.增加宠物寿命 = arg.增加宠物寿命;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int get是否有品质() {
        return this.是否有品质;
    }

    public void set是否有品质(int v) {
        this.是否有品质 = v;
    }

    public int get增加宠物寿命() {
        return this.增加宠物寿命;
    }

    public void set增加宠物寿命(int v) {
        this.增加宠物寿命 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
