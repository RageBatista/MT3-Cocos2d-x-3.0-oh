//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.SysConfig;

import java.util.Map;
import mytools.ConvMain;

public class SHotdeployClass implements ConvMain.Checkable, Comparable<SHotdeployClass> {
    public int id = 0;
    public String oldClassName = null;
    public String newClassName = null;

    public int compareTo(SHotdeployClass o) {
        return this.id - o.id;
    }

    public SHotdeployClass() {
    }

    public SHotdeployClass(SHotdeployClass arg) {
        this.id = arg.id;
        this.oldClassName = arg.oldClassName;
        this.newClassName = arg.newClassName;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getOldClassName() {
        return this.oldClassName;
    }

    public void setOldClassName(String v) {
        this.oldClassName = v;
    }

    public String getNewClassName() {
        return this.newClassName;
    }

    public void setNewClassName(String v) {
        this.newClassName = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
