//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class PetEquipItemShuXing extends ItemShuXing {
    public int pos = 0;
    public String pro = null;
    public String min = null;
    public String max = null;
    public String skill = null;
    public int itemid = 0;
    public int itemnum = 0;

    public int compareTo(PetEquipItemShuXing o) {
        return this.id - o.id;
    }

    public PetEquipItemShuXing(ItemShuXing arg) {
        super(arg);
    }

    public PetEquipItemShuXing() {
    }

    public PetEquipItemShuXing(PetEquipItemShuXing arg) {
        super(arg);
        this.pos = arg.pos;
        this.pro = arg.pro;
        this.min = arg.min;
        this.max = arg.max;
        this.skill = arg.skill;
        this.itemid = arg.itemid;
        this.itemnum = arg.itemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getPos() {
        return this.pos;
    }

    public void setPos(int v) {
        this.pos = v;
    }

    public String getPro() {
        return this.pro;
    }

    public void setPro(String v) {
        this.pro = v;
    }

    public String getMin() {
        return this.min;
    }

    public void setMin(String v) {
        this.min = v;
    }

    public String getMax() {
        return this.max;
    }

    public void setMax(String v) {
        this.max = v;
    }

    public String getSkill() {
        return this.skill;
    }

    public void setSkill(String v) {
        this.skill = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    public int getItemnum() {
        return this.itemnum;
    }

    public void setItemnum(int v) {
        this.itemnum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
