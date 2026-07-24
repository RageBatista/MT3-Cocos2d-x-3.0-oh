//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.Map;
import mytools.ConvMain;

public class HotfixXml2ModuleConfig implements ConvMain.Checkable, Comparable<HotfixXml2ModuleConfig> {
    public int id = 0;
    public String filename = null;
    public boolean canreload = false;
    public String module = null;

    public int compareTo(HotfixXml2ModuleConfig o) {
        return this.id - o.id;
    }

    public HotfixXml2ModuleConfig() {
    }

    public HotfixXml2ModuleConfig(HotfixXml2ModuleConfig arg) {
        this.id = arg.id;
        this.filename = arg.filename;
        this.canreload = arg.canreload;
        this.module = arg.module;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getFilename() {
        return this.filename;
    }

    public void setFilename(String v) {
        this.filename = v;
    }

    public boolean getCanreload() {
        return this.canreload;
    }

    public void setCanreload(boolean v) {
        this.canreload = v;
    }

    public String getModule() {
        return this.module;
    }

    public void setModule(String v) {
        this.module = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
