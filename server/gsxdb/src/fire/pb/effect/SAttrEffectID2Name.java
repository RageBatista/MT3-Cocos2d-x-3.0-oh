//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.effect;

import java.util.Map;
import mytools.ConvMain;

public class SAttrEffectID2Name implements ConvMain.Checkable, Comparable<SAttrEffectID2Name> {
    public int id = 0;
    public String classname = null;
    public String attrname = null;
    public double initValue = (double)0.0F;
    public int ablEffctId = 0;
    public String ablEffctName = null;
    public double ablLimit = (double)0.0F;
    public int pctEffctId = 0;
    public String pctEffctName = null;
    public double pctLimit = (double)0.0F;
    public int needSendAttr = 0;

    public int compareTo(SAttrEffectID2Name o) {
        return this.id - o.id;
    }

    public SAttrEffectID2Name() {
    }

    public SAttrEffectID2Name(SAttrEffectID2Name arg) {
        this.id = arg.id;
        this.classname = arg.classname;
        this.attrname = arg.attrname;
        this.initValue = arg.initValue;
        this.ablEffctId = arg.ablEffctId;
        this.ablEffctName = arg.ablEffctName;
        this.ablLimit = arg.ablLimit;
        this.pctEffctId = arg.pctEffctId;
        this.pctEffctName = arg.pctEffctName;
        this.pctLimit = arg.pctLimit;
        this.needSendAttr = arg.needSendAttr;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    public String getAttrname() {
        return this.attrname;
    }

    public void setAttrname(String v) {
        this.attrname = v;
    }

    public double getInitValue() {
        return this.initValue;
    }

    public void setInitValue(double v) {
        this.initValue = v;
    }

    public int getAblEffctId() {
        return this.ablEffctId;
    }

    public void setAblEffctId(int v) {
        this.ablEffctId = v;
    }

    public String getAblEffctName() {
        return this.ablEffctName;
    }

    public void setAblEffctName(String v) {
        this.ablEffctName = v;
    }

    public double getAblLimit() {
        return this.ablLimit;
    }

    public void setAblLimit(double v) {
        this.ablLimit = v;
    }

    public int getPctEffctId() {
        return this.pctEffctId;
    }

    public void setPctEffctId(int v) {
        this.pctEffctId = v;
    }

    public String getPctEffctName() {
        return this.pctEffctName;
    }

    public void setPctEffctName(String v) {
        this.pctEffctName = v;
    }

    public double getPctLimit() {
        return this.pctLimit;
    }

    public void setPctLimit(double v) {
        this.pctLimit = v;
    }

    public int getNeedSendAttr() {
        return this.needSendAttr;
    }

    public void setNeedSendAttr(int v) {
        this.needSendAttr = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
