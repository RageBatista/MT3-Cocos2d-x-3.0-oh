//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class SShenShouInc implements ConvMain.Checkable, Comparable<SShenShouInc> {
    public int id = 0;
    public int petid = 0;
    public int inccount = 0;
    public int attinc = 0;
    public int atkinc = 0;
    public int definc = 0;
    public int hpinc = 0;
    public int mpinc = 0;
    public int spdinc = 0;
    public int inclv = 0;

    public int compareTo(SShenShouInc o) {
        return this.id - o.id;
    }

    public SShenShouInc() {
    }

    public SShenShouInc(SShenShouInc arg) {
        this.id = arg.id;
        this.petid = arg.petid;
        this.inccount = arg.inccount;
        this.attinc = arg.attinc;
        this.atkinc = arg.atkinc;
        this.definc = arg.definc;
        this.hpinc = arg.hpinc;
        this.mpinc = arg.mpinc;
        this.spdinc = arg.spdinc;
        this.inclv = arg.inclv;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getPetid() {
        return this.petid;
    }

    public void setPetid(int v) {
        this.petid = v;
    }

    public int getInccount() {
        return this.inccount;
    }

    public void setInccount(int v) {
        this.inccount = v;
    }

    public int getAttinc() {
        return this.attinc;
    }

    public void setAttinc(int v) {
        this.attinc = v;
    }

    public int getAtkinc() {
        return this.atkinc;
    }

    public void setAtkinc(int v) {
        this.atkinc = v;
    }

    public int getDefinc() {
        return this.definc;
    }

    public void setDefinc(int v) {
        this.definc = v;
    }

    public int getHpinc() {
        return this.hpinc;
    }

    public void setHpinc(int v) {
        this.hpinc = v;
    }

    public int getMpinc() {
        return this.mpinc;
    }

    public void setMpinc(int v) {
        this.mpinc = v;
    }

    public int getSpdinc() {
        return this.spdinc;
    }

    public void setSpdinc(int v) {
        this.spdinc = v;
    }

    public int getInclv() {
        return this.inclv;
    }

    public void setInclv(int v) {
        this.inclv = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
