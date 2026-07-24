//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class RoleModData implements ConvMain.Checkable, Comparable<RoleModData> {
    public int id = 0;
    public int consinit = 0;
    public int iqinit = 0;
    public int strinit = 0;
    public int enduinit = 0;
    public int agiinit = 0;
    public int hpinit = 0;
    public int mpinit = 0;
    public int damageinit = 0;
    public int defendinit = 0;
    public int magicattackinit = 0;
    public int magicdefendinit = 0;
    public int hitinit = 0;
    public int dodgeinit = 0;
    public int speedinit = 0;
    public int danderlimit = 0;
    public int medical = 0;
    public int sealhit = 0;
    public int unseal = 0;

    public int compareTo(RoleModData o) {
        return this.id - o.id;
    }

    public RoleModData() {
    }

    public RoleModData(RoleModData arg) {
        this.id = arg.id;
        this.consinit = arg.consinit;
        this.iqinit = arg.iqinit;
        this.strinit = arg.strinit;
        this.enduinit = arg.enduinit;
        this.agiinit = arg.agiinit;
        this.hpinit = arg.hpinit;
        this.mpinit = arg.mpinit;
        this.damageinit = arg.damageinit;
        this.defendinit = arg.defendinit;
        this.magicattackinit = arg.magicattackinit;
        this.magicdefendinit = arg.magicdefendinit;
        this.hitinit = arg.hitinit;
        this.dodgeinit = arg.dodgeinit;
        this.speedinit = arg.speedinit;
        this.danderlimit = arg.danderlimit;
        this.medical = arg.medical;
        this.sealhit = arg.sealhit;
        this.unseal = arg.unseal;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getConsinit() {
        return this.consinit;
    }

    public void setConsinit(int v) {
        this.consinit = v;
    }

    public int getIqinit() {
        return this.iqinit;
    }

    public void setIqinit(int v) {
        this.iqinit = v;
    }

    public int getStrinit() {
        return this.strinit;
    }

    public void setStrinit(int v) {
        this.strinit = v;
    }

    public int getEnduinit() {
        return this.enduinit;
    }

    public void setEnduinit(int v) {
        this.enduinit = v;
    }

    public int getAgiinit() {
        return this.agiinit;
    }

    public void setAgiinit(int v) {
        this.agiinit = v;
    }

    public int getHpinit() {
        return this.hpinit;
    }

    public void setHpinit(int v) {
        this.hpinit = v;
    }

    public int getMpinit() {
        return this.mpinit;
    }

    public void setMpinit(int v) {
        this.mpinit = v;
    }

    public int getDamageinit() {
        return this.damageinit;
    }

    public void setDamageinit(int v) {
        this.damageinit = v;
    }

    public int getDefendinit() {
        return this.defendinit;
    }

    public void setDefendinit(int v) {
        this.defendinit = v;
    }

    public int getMagicattackinit() {
        return this.magicattackinit;
    }

    public void setMagicattackinit(int v) {
        this.magicattackinit = v;
    }

    public int getMagicdefendinit() {
        return this.magicdefendinit;
    }

    public void setMagicdefendinit(int v) {
        this.magicdefendinit = v;
    }

    public int getHitinit() {
        return this.hitinit;
    }

    public void setHitinit(int v) {
        this.hitinit = v;
    }

    public int getDodgeinit() {
        return this.dodgeinit;
    }

    public void setDodgeinit(int v) {
        this.dodgeinit = v;
    }

    public int getSpeedinit() {
        return this.speedinit;
    }

    public void setSpeedinit(int v) {
        this.speedinit = v;
    }

    public int getDanderlimit() {
        return this.danderlimit;
    }

    public void setDanderlimit(int v) {
        this.danderlimit = v;
    }

    public int getMedical() {
        return this.medical;
    }

    public void setMedical(int v) {
        this.medical = v;
    }

    public int getSealhit() {
        return this.sealhit;
    }

    public void setSealhit(int v) {
        this.sealhit = v;
    }

    public int getUnseal() {
        return this.unseal;
    }

    public void setUnseal(int v) {
        this.unseal = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
