//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SCreateRoleConfig implements ConvMain.Checkable, Comparable<SCreateRoleConfig> {
    public int id = 0;
    public int sex = 0;
    public ArrayList<Integer> schools;
    public ArrayList<Integer> initequip;

    public int compareTo(SCreateRoleConfig o) {
        return this.id - o.id;
    }

    public SCreateRoleConfig() {
    }

    public SCreateRoleConfig(SCreateRoleConfig arg) {
        this.id = arg.id;
        this.sex = arg.sex;
        this.schools = arg.schools;
        this.initequip = arg.initequip;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSex() {
        return this.sex;
    }

    public void setSex(int v) {
        this.sex = v;
    }

    public ArrayList<Integer> getSchools() {
        return this.schools;
    }

    public void setSchools(ArrayList<Integer> v) {
        this.schools = v;
    }

    public ArrayList<Integer> getInitequip() {
        return this.initequip;
    }

    public void setInitequip(ArrayList<Integer> v) {
        this.initequip = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
