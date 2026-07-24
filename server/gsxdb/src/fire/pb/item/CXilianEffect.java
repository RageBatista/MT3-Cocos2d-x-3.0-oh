//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class CXilianEffect implements ConvMain.Checkable, Comparable<CXilianEffect> {
    public int id = 0;
    public int attrId = 0;
    public String attrName = null;
    public int attrInitvalue = 0;
    public int attrAddvalue = 0;

    public int compareTo(CXilianEffect var1) {
        return this.id - var1.id;
    }

    public CXilianEffect() {
    }

    public CXilianEffect(CXilianEffect var1) {
        this.id = var1.id;
        this.attrId = var1.attrId;
        this.attrName = var1.attrName;
        this.attrInitvalue = var1.attrInitvalue;
        this.attrAddvalue = var1.attrAddvalue;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> var1) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public int getAttrId() {
        return this.attrId;
    }

    public void setAttrId(int var1) {
        this.attrId = var1;
    }

    public String getAttrName() {
        return this.attrName;
    }

    public void setAttrName(String var1) {
        this.attrName = var1;
    }

    public int getAttrInitvalue() {
        return this.attrInitvalue;
    }

    public void setAttrInitvalue(int var1) {
        this.attrInitvalue = var1;
    }

    public int getAttrAddvalue() {
        return this.attrAddvalue;
    }

    public void setAttrAddvalue(int var1) {
        this.attrAddvalue = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
