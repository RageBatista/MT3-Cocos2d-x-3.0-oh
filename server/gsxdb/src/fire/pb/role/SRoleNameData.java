//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SRoleNameData implements ConvMain.Checkable, Comparable<SRoleNameData> {
    public int id = 0;
    public String xManName = null;
    public String xWomanName = null;
    public String mWomanName = null;
    public String mManName = null;

    public int compareTo(SRoleNameData o) {
        return this.id - o.id;
    }

    public SRoleNameData() {
    }

    public SRoleNameData(SRoleNameData arg) {
        this.id = arg.id;
        this.xManName = arg.xManName;
        this.xWomanName = arg.xWomanName;
        this.mWomanName = arg.mWomanName;
        this.mManName = arg.mManName;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getXManName() {
        return this.xManName;
    }

    public void setXManName(String v) {
        this.xManName = v;
    }

    public String getXWomanName() {
        return this.xWomanName;
    }

    public void setXWomanName(String v) {
        this.xWomanName = v;
    }

    public String getMWomanName() {
        return this.mWomanName;
    }

    public void setMWomanName(String v) {
        this.mWomanName = v;
    }

    public String getMManName() {
        return this.mManName;
    }

    public void setMManName(String v) {
        this.mManName = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
