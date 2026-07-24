//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class PetAttrModData implements ConvMain.Checkable, Comparable<PetAttrModData> {
    public int id = 0;
    public double consfactor = (double)0.0F;
    public double iqfactor = (double)0.0F;
    public double strfactor = (double)0.0F;
    public double endufactor = (double)0.0F;
    public double agifactor = (double)0.0F;

    public int compareTo(PetAttrModData o) {
        return this.id - o.id;
    }

    public PetAttrModData() {
    }

    public PetAttrModData(PetAttrModData arg) {
        this.id = arg.id;
        this.consfactor = arg.consfactor;
        this.iqfactor = arg.iqfactor;
        this.strfactor = arg.strfactor;
        this.endufactor = arg.endufactor;
        this.agifactor = arg.agifactor;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public double getConsfactor() {
        return this.consfactor;
    }

    public void setConsfactor(double v) {
        this.consfactor = v;
    }

    public double getIqfactor() {
        return this.iqfactor;
    }

    public void setIqfactor(double v) {
        this.iqfactor = v;
    }

    public double getStrfactor() {
        return this.strfactor;
    }

    public void setStrfactor(double v) {
        this.strfactor = v;
    }

    public double getEndufactor() {
        return this.endufactor;
    }

    public void setEndufactor(double v) {
        this.endufactor = v;
    }

    public double getAgifactor() {
        return this.agifactor;
    }

    public void setAgifactor(double v) {
        this.agifactor = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
