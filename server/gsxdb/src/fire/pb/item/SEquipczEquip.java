//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipczEquip implements ConvMain.Checkable, Comparable<SEquipczEquip> {
    public int id = 0;
    public int nextid1 = 0;
    public int nextid2 = 0;
    public ArrayList<Integer> needid;
    public ArrayList<Integer> needid1num;
    public ArrayList<Integer> needid2num;

    public int compareTo(SEquipczEquip o) {
        return this.id - o.id;
    }

    public SEquipczEquip() {
    }

    public SEquipczEquip(SEquipczEquip arg) {
        this.id = arg.id;
        this.nextid1 = arg.nextid1;
        this.nextid2 = arg.nextid2;
        this.needid = arg.needid;
        this.needid1num = arg.needid1num;
        this.needid2num = arg.needid2num;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNextid1() {
        return this.nextid1;
    }

    public void setNextid1(int v) {
        this.nextid1 = v;
    }

    public int getNextid2() {
        return this.nextid2;
    }

    public void setNextid2(int v) {
        this.nextid2 = v;
    }

    public ArrayList<Integer> getNeedid() {
        return this.needid;
    }

    public void setNeedid(ArrayList<Integer> v) {
        this.needid = v;
    }

    public ArrayList<Integer> getNeedid1num() {
        return this.needid1num;
    }

    public void setNeedid1num(ArrayList<Integer> v) {
        this.needid1num = v;
    }

    public ArrayList<Integer> getNeedid2num() {
        return this.needid2num;
    }

    public void setNeedid2num(ArrayList<Integer> v) {
        this.needid2num = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
