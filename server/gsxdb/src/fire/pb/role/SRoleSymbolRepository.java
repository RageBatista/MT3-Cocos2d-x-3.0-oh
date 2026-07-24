//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SRoleSymbolRepository implements ConvMain.Checkable, Comparable<SRoleSymbolRepository> {
    public int id = 0;
    public String symbol = null;
    public int type = 0;
    public int gender = 0;

    public int compareTo(SRoleSymbolRepository o) {
        return this.id - o.id;
    }

    public SRoleSymbolRepository() {
    }

    public SRoleSymbolRepository(SRoleSymbolRepository arg) {
        this.id = arg.id;
        this.symbol = arg.symbol;
        this.type = arg.type;
        this.gender = arg.gender;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getSymbol() {
        return this.symbol;
    }

    public void setSymbol(String v) {
        this.symbol = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getGender() {
        return this.gender;
    }

    public void setGender(int v) {
        this.gender = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
