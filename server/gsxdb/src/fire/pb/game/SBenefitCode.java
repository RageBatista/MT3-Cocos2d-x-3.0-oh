//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class SBenefitCode implements ConvMain.Checkable, Comparable<SBenefitCode> {
    public int id = 0;
    public String code = null;
    public int itemid = 0;
    public int itemnum = 0;

    public int compareTo(SBenefitCode o) {
        return this.id - o.id;
    }

    public SBenefitCode() {
    }

    public SBenefitCode(SBenefitCode arg) {
        this.id = arg.id;
        this.code = arg.code;
        this.itemid = arg.itemid;
        this.itemnum = arg.itemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getCode() {
        return this.code;
    }

    public void setCode(String v) {
        this.code = v;
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
