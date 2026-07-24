//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class STransferRoleTable implements ConvMain.Checkable, Comparable<STransferRoleTable> {
    public int id = 0;
    public String tableName = null;

    public int compareTo(STransferRoleTable o) {
        return this.id - o.id;
    }

    public STransferRoleTable() {
    }

    public STransferRoleTable(STransferRoleTable arg) {
        this.id = arg.id;
        this.tableName = arg.tableName;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getTableName() {
        return this.tableName;
    }

    public void setTableName(String v) {
        this.tableName = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
