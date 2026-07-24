//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SRankListNumConfig implements ConvMain.Checkable, Comparable<SRankListNumConfig> {
    public int id = 0;
    public int personNum = 0;
    public String namename = null;

    public int compareTo(SRankListNumConfig o) {
        return this.id - o.id;
    }

    public SRankListNumConfig() {
    }

    public SRankListNumConfig(SRankListNumConfig arg) {
        this.id = arg.id;
        this.personNum = arg.personNum;
        this.namename = arg.namename;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getPersonNum() {
        return this.personNum;
    }

    public void setPersonNum(int v) {
        this.personNum = v;
    }

    public String getNamename() {
        return this.namename;
    }

    public void setNamename(String v) {
        this.namename = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
