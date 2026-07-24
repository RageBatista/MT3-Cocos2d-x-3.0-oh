//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class PetItemShuXing extends ItemShuXing {
    public int skillid = 0;
    public int addExp = 0;
    public int addLife = 0;
    public int treasure = 0;

    public int compareTo(PetItemShuXing o) {
        return this.id - o.id;
    }

    public PetItemShuXing(ItemShuXing arg) {
        super(arg);
    }

    public PetItemShuXing() {
    }

    public PetItemShuXing(PetItemShuXing arg) {
        super(arg);
        this.skillid = arg.skillid;
        this.addExp = arg.addExp;
        this.addLife = arg.addLife;
        this.treasure = arg.treasure;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    public int getAddExp() {
        return this.addExp;
    }

    public void setAddExp(int v) {
        this.addExp = v;
    }

    public int getAddLife() {
        return this.addLife;
    }

    public void setAddLife(int v) {
        this.addLife = v;
    }

    public int getTreasure() {
        return this.treasure;
    }

    public void setTreasure(int v) {
        this.treasure = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
