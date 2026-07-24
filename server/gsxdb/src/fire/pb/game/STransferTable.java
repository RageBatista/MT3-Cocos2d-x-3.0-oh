//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class STransferTable implements ConvMain.Checkable, Comparable<STransferTable> {
    public int id = 0;
    public String tableName = null;
    public String valueType = null;
    public String keyType = null;

    public int compareTo(STransferTable o) {
        return this.id - o.id;
    }

    public STransferTable() {
    }

    public STransferTable(STransferTable arg) {
        this.id = arg.id;
        this.tableName = arg.tableName;
        this.valueType = arg.valueType;
        this.keyType = arg.keyType;
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

    public String getValueType() {
        return this.valueType;
    }

    public void setValueType(String v) {
        this.valueType = v;
    }

    public String getKeyType() {
        return this.keyType;
    }

    public void setKeyType(String v) {
        this.keyType = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
