//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;

public class SWildMonsterConfig extends MonsterConfig {
    public int initPoint = 0;
    public int initPointAssignType = 0;
    public ArrayList<Integer> addpoint;
    public int attackapt = 0;
    public int defendapt = 0;
    public int phyforceapt = 0;
    public int magicapt = 0;
    public int speedapt = 0;
    public int dodgeapt = 0;
    public int growrate = 0;
    public int healgrow = 0;
    public int ctrlhitgrow = 0;
    public int ctrlresistgrow = 0;
    public ArrayList<SMonsterSkill> skills;

    public int compareTo(SWildMonsterConfig o) {
        return this.id - o.id;
    }

    public SWildMonsterConfig(MonsterConfig arg) {
        super(arg);
    }

    public SWildMonsterConfig() {
    }

    public SWildMonsterConfig(SWildMonsterConfig arg) {
        super(arg);
        this.initPoint = arg.initPoint;
        this.initPointAssignType = arg.initPointAssignType;
        this.addpoint = arg.addpoint;
        this.attackapt = arg.attackapt;
        this.defendapt = arg.defendapt;
        this.phyforceapt = arg.phyforceapt;
        this.magicapt = arg.magicapt;
        this.speedapt = arg.speedapt;
        this.dodgeapt = arg.dodgeapt;
        this.growrate = arg.growrate;
        this.healgrow = arg.healgrow;
        this.ctrlhitgrow = arg.ctrlhitgrow;
        this.ctrlresistgrow = arg.ctrlresistgrow;
        this.skills = arg.skills;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getInitPoint() {
        return this.initPoint;
    }

    public void setInitPoint(int v) {
        this.initPoint = v;
    }

    public int getInitPointAssignType() {
        return this.initPointAssignType;
    }

    public void setInitPointAssignType(int v) {
        this.initPointAssignType = v;
    }

    public ArrayList<Integer> getAddpoint() {
        return this.addpoint;
    }

    public void setAddpoint(ArrayList<Integer> v) {
        this.addpoint = v;
    }

    public int getAttackapt() {
        return this.attackapt;
    }

    public void setAttackapt(int v) {
        this.attackapt = v;
    }

    public int getDefendapt() {
        return this.defendapt;
    }

    public void setDefendapt(int v) {
        this.defendapt = v;
    }

    public int getPhyforceapt() {
        return this.phyforceapt;
    }

    public void setPhyforceapt(int v) {
        this.phyforceapt = v;
    }

    public int getMagicapt() {
        return this.magicapt;
    }

    public void setMagicapt(int v) {
        this.magicapt = v;
    }

    public int getSpeedapt() {
        return this.speedapt;
    }

    public void setSpeedapt(int v) {
        this.speedapt = v;
    }

    public int getDodgeapt() {
        return this.dodgeapt;
    }

    public void setDodgeapt(int v) {
        this.dodgeapt = v;
    }

    public int getGrowrate() {
        return this.growrate;
    }

    public void setGrowrate(int v) {
        this.growrate = v;
    }

    public int getHealgrow() {
        return this.healgrow;
    }

    public void setHealgrow(int v) {
        this.healgrow = v;
    }

    public int getCtrlhitgrow() {
        return this.ctrlhitgrow;
    }

    public void setCtrlhitgrow(int v) {
        this.ctrlhitgrow = v;
    }

    public int getCtrlresistgrow() {
        return this.ctrlresistgrow;
    }

    public void setCtrlresistgrow(int v) {
        this.ctrlresistgrow = v;
    }

    public ArrayList<SMonsterSkill> getSkills() {
        return this.skills;
    }

    public void setSkills(ArrayList<SMonsterSkill> v) {
        this.skills = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
