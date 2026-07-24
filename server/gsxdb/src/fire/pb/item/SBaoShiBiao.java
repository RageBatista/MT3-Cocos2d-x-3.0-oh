//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SBaoShiBiao implements ConvMain.Checkable, Comparable<SBaoShiBiao> {
    public int id = 0;
    public int type = 0;
    public int level = 0;
    public int nextDiamond = 0;
    public int prob = 0;
    public int shape = 0;
    public int equip1 = 0;
    public int equip2 = 0;
    public int resolve = 0;
    public int resolveItem = 0;
    public int resolveNum = 0;

    public int compareTo(SBaoShiBiao o) {
        return this.id - o.id;
    }

    public SBaoShiBiao() {
    }

    public SBaoShiBiao(SBaoShiBiao arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.level = arg.level;
        this.nextDiamond = arg.nextDiamond;
        this.prob = arg.prob;
        this.shape = arg.shape;
        this.equip1 = arg.equip1;
        this.equip2 = arg.equip2;
        this.resolve = arg.resolve;
        this.resolveItem = arg.resolveItem;
        this.resolveNum = arg.resolveNum;
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

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public int getNextDiamond() {
        return this.nextDiamond;
    }

    public void setNextDiamond(int v) {
        this.nextDiamond = v;
    }

    public int getProb() {
        return this.prob;
    }

    public void setProb(int v) {
        this.prob = v;
    }

    public int getShape() {
        return this.shape;
    }

    public void setShape(int v) {
        this.shape = v;
    }

    public int getEquip1() {
        return this.equip1;
    }

    public void setEquip1(int v) {
        this.equip1 = v;
    }

    public int getEquip2() {
        return this.equip2;
    }

    public void setEquip2(int v) {
        this.equip2 = v;
    }

    public int getResolve() {
        return this.resolve;
    }

    public void setResolve(int v) {
        this.resolve = v;
    }

    public int getResolveItem() {
        return this.resolveItem;
    }

    public void setResolveItem(int v) {
        this.resolveItem = v;
    }

    public int getResolveNum() {
        return this.resolveNum;
    }

    public void setResolveNum(int v) {
        this.resolveNum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
