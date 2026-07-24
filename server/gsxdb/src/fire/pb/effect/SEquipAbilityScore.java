//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.effect;

import java.util.Map;
import mytools.ConvMain;

public class SEquipAbilityScore implements ConvMain.Checkable, Comparable<SEquipAbilityScore> {
    public int id = 0;
    public String name = null;
    public double coefficient = (double)0.0F;
    public double weapon = (double)0.0F;
    public double armor = (double)0.0F;
    public double headdress = (double)0.0F;
    public double accessory = (double)0.0F;
    public double belt = (double)0.0F;
    public double boot = (double)0.0F;

    public int compareTo(SEquipAbilityScore o) {
        return this.id - o.id;
    }

    public SEquipAbilityScore() {
    }

    public SEquipAbilityScore(SEquipAbilityScore arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.coefficient = arg.coefficient;
        this.weapon = arg.weapon;
        this.armor = arg.armor;
        this.headdress = arg.headdress;
        this.accessory = arg.accessory;
        this.belt = arg.belt;
        this.boot = arg.boot;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public double getCoefficient() {
        return this.coefficient;
    }

    public void setCoefficient(double v) {
        this.coefficient = v;
    }

    public double getWeapon() {
        return this.weapon;
    }

    public void setWeapon(double v) {
        this.weapon = v;
    }

    public double getArmor() {
        return this.armor;
    }

    public void setArmor(double v) {
        this.armor = v;
    }

    public double getHeaddress() {
        return this.headdress;
    }

    public void setHeaddress(double v) {
        this.headdress = v;
    }

    public double getAccessory() {
        return this.accessory;
    }

    public void setAccessory(double v) {
        this.accessory = v;
    }

    public double getBelt() {
        return this.belt;
    }

    public void setBelt(double v) {
        this.belt = v;
    }

    public double getBoot() {
        return this.boot;
    }

    public void setBoot(double v) {
        this.boot = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
