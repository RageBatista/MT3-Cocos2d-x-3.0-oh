//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipAddattributerandomlib implements ConvMain.Checkable, Comparable<SEquipAddattributerandomlib> {
    public int id = 0;
    public ArrayList<Integer> addattributer;
    public ArrayList<Integer> addattributerquanzhong;
    public int allquanzhong = 0;

    public int compareTo(SEquipAddattributerandomlib o) {
        return this.id - o.id;
    }

    public SEquipAddattributerandomlib() {
    }

    public SEquipAddattributerandomlib(SEquipAddattributerandomlib arg) {
        this.id = arg.id;
        this.addattributer = arg.addattributer;
        this.addattributerquanzhong = arg.addattributerquanzhong;
        this.allquanzhong = arg.allquanzhong;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getAddattributer() {
        return this.addattributer;
    }

    public void setAddattributer(ArrayList<Integer> v) {
        this.addattributer = v;
    }

    public ArrayList<Integer> getAddattributerquanzhong() {
        return this.addattributerquanzhong;
    }

    public void setAddattributerquanzhong(ArrayList<Integer> v) {
        this.addattributerquanzhong = v;
    }

    public int getAllquanzhong() {
        return this.allquanzhong;
    }

    public void setAllquanzhong(int v) {
        this.allquanzhong = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
