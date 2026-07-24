//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SXilianEffect implements ConvMain.Checkable, Comparable<SXilianEffect> {
    public int id = 0;
    public int attrId = 0;
    public String attrName = null;
    public int attrInitvalue = 0;
    public int attrAddvalue = 0;

    public int compareTo(SXilianEffect o) {
        return this.id - o.id;
    }

    public SXilianEffect() {
    }

    public SXilianEffect(SXilianEffect arg) {
        this.id = arg.id;
        this.attrId = arg.attrId;
        this.attrName = arg.attrName;
        this.attrInitvalue = arg.attrInitvalue;
        this.attrAddvalue = arg.attrAddvalue;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getAttrId() {
        return this.attrId;
    }

    public void setAttrId(int v) {
        this.attrId = v;
    }

    public String getAttrName() {
        return this.attrName;
    }

    public void setAttrName(String v) {
        this.attrName = v;
    }

    public int getAttrInitvalue() {
        return this.attrInitvalue;
    }

    public void setAttrInitvalue(int v) {
        this.attrInitvalue = v;
    }

    public int getAttrAddvalue() {
        return this.attrAddvalue;
    }

    public void setAttrAddvalue(int v) {
        this.attrAddvalue = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
