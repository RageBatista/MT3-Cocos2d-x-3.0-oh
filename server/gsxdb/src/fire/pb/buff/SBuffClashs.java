//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.buff;

import java.util.Map;
import mytools.ConvMain;

public class SBuffClashs implements ConvMain.Checkable, Comparable<SBuffClashs> {
    public int id = 0;
    public String name = null;
    public String clashbuffs = null;
    public String invalidbuffs = null;
    public String overridebuffs = null;
    public String tips = null;
    public String clashmapid = null;

    public int compareTo(SBuffClashs o) {
        return this.id - o.id;
    }

    public SBuffClashs() {
    }

    public SBuffClashs(SBuffClashs arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.clashbuffs = arg.clashbuffs;
        this.invalidbuffs = arg.invalidbuffs;
        this.overridebuffs = arg.overridebuffs;
        this.tips = arg.tips;
        this.clashmapid = arg.clashmapid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
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

    public String getClashbuffs() {
        return this.clashbuffs;
    }

    public void setClashbuffs(String v) {
        this.clashbuffs = v;
    }

    public String getInvalidbuffs() {
        return this.invalidbuffs;
    }

    public void setInvalidbuffs(String v) {
        this.invalidbuffs = v;
    }

    public String getOverridebuffs() {
        return this.overridebuffs;
    }

    public void setOverridebuffs(String v) {
        this.overridebuffs = v;
    }

    public String getTips() {
        return this.tips;
    }

    public void setTips(String v) {
        this.tips = v;
    }

    public String getClashmapid() {
        return this.clashmapid;
    }

    public void setClashmapid(String v) {
        this.clashmapid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
