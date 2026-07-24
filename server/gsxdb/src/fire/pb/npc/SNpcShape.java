//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SNpcShape implements ConvMain.Checkable, Comparable<SNpcShape> {
    public int id = 0;
    public String shape = null;
    public String roleimage = null;
    public int headID = 0;
    public int littleheadID = 0;
    public String name = null;
    public int dir = 0;
    public int shadow = 0;
    public String attack = null;
    public String magic = null;
    public int nearorfar = 0;
    public int shadertype = 0;
    public ArrayList<Integer> part0;
    public ArrayList<Integer> part1;
    public ArrayList<Integer> part2;
    public int showWeaponId = 0;
    public int showHorseShape = 0;

    public int compareTo(SNpcShape o) {
        return this.id - o.id;
    }

    public SNpcShape() {
    }

    public SNpcShape(SNpcShape arg) {
        this.id = arg.id;
        this.shape = arg.shape;
        this.roleimage = arg.roleimage;
        this.headID = arg.headID;
        this.littleheadID = arg.littleheadID;
        this.name = arg.name;
        this.dir = arg.dir;
        this.shadow = arg.shadow;
        this.attack = arg.attack;
        this.magic = arg.magic;
        this.nearorfar = arg.nearorfar;
        this.shadertype = arg.shadertype;
        this.part0 = arg.part0;
        this.part1 = arg.part1;
        this.part2 = arg.part2;
        this.showWeaponId = arg.showWeaponId;
        this.showHorseShape = arg.showHorseShape;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getShape() {
        return this.shape;
    }

    public void setShape(String v) {
        this.shape = v;
    }

    public String getRoleimage() {
        return this.roleimage;
    }

    public void setRoleimage(String v) {
        this.roleimage = v;
    }

    public int getHeadID() {
        return this.headID;
    }

    public void setHeadID(int v) {
        this.headID = v;
    }

    public int getLittleheadID() {
        return this.littleheadID;
    }

    public void setLittleheadID(int v) {
        this.littleheadID = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getDir() {
        return this.dir;
    }

    public void setDir(int v) {
        this.dir = v;
    }

    public int getShadow() {
        return this.shadow;
    }

    public void setShadow(int v) {
        this.shadow = v;
    }

    public String getAttack() {
        return this.attack;
    }

    public void setAttack(String v) {
        this.attack = v;
    }

    public String getMagic() {
        return this.magic;
    }

    public void setMagic(String v) {
        this.magic = v;
    }

    public int getNearorfar() {
        return this.nearorfar;
    }

    public void setNearorfar(int v) {
        this.nearorfar = v;
    }

    public int getShadertype() {
        return this.shadertype;
    }

    public void setShadertype(int v) {
        this.shadertype = v;
    }

    public ArrayList<Integer> getPart0() {
        return this.part0;
    }

    public void setPart0(ArrayList<Integer> v) {
        this.part0 = v;
    }

    public ArrayList<Integer> getPart1() {
        return this.part1;
    }

    public void setPart1(ArrayList<Integer> v) {
        this.part1 = v;
    }

    public ArrayList<Integer> getPart2() {
        return this.part2;
    }

    public void setPart2(ArrayList<Integer> v) {
        this.part2 = v;
    }

    public int getShowWeaponId() {
        return this.showWeaponId;
    }

    public void setShowWeaponId(int v) {
        this.showWeaponId = v;
    }

    public int getShowHorseShape() {
        return this.showHorseShape;
    }

    public void setShowHorseShape(int v) {
        this.showHorseShape = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
