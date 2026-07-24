//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;

public class gemItemShuXing extends ItemShuXing {
    public ArrayList<Integer> effectname;
    public ArrayList<Integer> effect;
    public int gemType = 0;
    public int isallfenjie = 0;

    public int compareTo(gemItemShuXing o) {
        return this.id - o.id;
    }

    public gemItemShuXing(ItemShuXing arg) {
        super(arg);
    }

    public gemItemShuXing() {
    }

    public gemItemShuXing(gemItemShuXing arg) {
        super(arg);
        this.effectname = arg.effectname;
        this.effect = arg.effect;
        this.gemType = arg.gemType;
        this.isallfenjie = arg.isallfenjie;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public ArrayList<Integer> getEffectname() {
        return this.effectname;
    }

    public void setEffectname(ArrayList<Integer> v) {
        this.effectname = v;
    }

    public ArrayList<Integer> getEffect() {
        return this.effect;
    }

    public void setEffect(ArrayList<Integer> v) {
        this.effect = v;
    }

    public int getGemType() {
        return this.gemType;
    }

    public void setGemType(int v) {
        this.gemType = v;
    }

    public int getIsallfenjie() {
        return this.isallfenjie;
    }

    public void setIsallfenjie(int v) {
        this.isallfenjie = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
