//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class ModuleInfo implements ConvMain.Checkable, Comparable<ModuleInfo> {
    public int id = 0;
    public String name = null;
    public String classname = null;
    public ArrayList<String> dep;

    public int compareTo(ModuleInfo o) {
        return this.id - o.id;
    }

    public ModuleInfo() {
    }

    public ModuleInfo(ModuleInfo arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.classname = arg.classname;
        this.dep = arg.dep;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    public ArrayList<String> getDep() {
        return this.dep;
    }

    public void setDep(ArrayList<String> v) {
        this.dep = v;
    }
}
