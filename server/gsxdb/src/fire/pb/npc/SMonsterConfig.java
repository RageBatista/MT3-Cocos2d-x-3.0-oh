//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;

public class SMonsterConfig extends MonsterExtraAttrConfig {
    public int daodi = 0;
    public int DefaultBattleEp = 0;
    public int MaxSp = 0;
    public int DefaultBattleSp = 0;
    public double hpMaxAttackFactor = (double)0.0F;
    public double hpMaxFactor = (double)0.0F;
    public double hpMaxConstant = (double)0.0F;
    public double mpMaxFactor = (double)0.0F;
    public double mpMaxConstant = (double)0.0F;
    public double attackFactor = (double)0.0F;
    public double attackConstant = (double)0.0F;
    public double defFactor = (double)0.0F;
    public double defConstant = (double)0.0F;
    public double magicattFactor = (double)0.0F;
    public double magicattConstant = (double)0.0F;
    public double magicDefFactor = (double)0.0F;
    public double magicDefConstant = (double)0.0F;
    public double attallFactor = (double)0.0F;
    public double attallConstant = (double)0.0F;
    public double speedFactor = (double)0.0F;
    public double speedConstant = (double)0.0F;
    public double medicalFactor = (double)0.0F;
    public double medicalConstant = (double)0.0F;
    public double sealhitFactor = (double)0.0F;
    public double sealhitConstant = (double)0.0F;
    public double unsealFactor = (double)0.0F;
    public double unsealConstant = (double)0.0F;
    public ArrayList<SMonsterSkill> skills;

    public int compareTo(SMonsterConfig o) {
        return this.id - o.id;
    }

    public SMonsterConfig(MonsterExtraAttrConfig arg) {
        super(arg);
    }

    public SMonsterConfig() {
    }

    public SMonsterConfig(SMonsterConfig arg) {
        super(arg);
        this.daodi = arg.daodi;
        this.DefaultBattleEp = arg.DefaultBattleEp;
        this.MaxSp = arg.MaxSp;
        this.DefaultBattleSp = arg.DefaultBattleSp;
        this.hpMaxAttackFactor = arg.hpMaxAttackFactor;
        this.hpMaxFactor = arg.hpMaxFactor;
        this.hpMaxConstant = arg.hpMaxConstant;
        this.mpMaxFactor = arg.mpMaxFactor;
        this.mpMaxConstant = arg.mpMaxConstant;
        this.attackFactor = arg.attackFactor;
        this.attackConstant = arg.attackConstant;
        this.defFactor = arg.defFactor;
        this.defConstant = arg.defConstant;
        this.magicattFactor = arg.magicattFactor;
        this.magicattConstant = arg.magicattConstant;
        this.magicDefFactor = arg.magicDefFactor;
        this.magicDefConstant = arg.magicDefConstant;
        this.attallFactor = arg.attallFactor;
        this.attallConstant = arg.attallConstant;
        this.speedFactor = arg.speedFactor;
        this.speedConstant = arg.speedConstant;
        this.medicalFactor = arg.medicalFactor;
        this.medicalConstant = arg.medicalConstant;
        this.sealhitFactor = arg.sealhitFactor;
        this.sealhitConstant = arg.sealhitConstant;
        this.unsealFactor = arg.unsealFactor;
        this.unsealConstant = arg.unsealConstant;
        this.skills = arg.skills;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getDaodi() {
        return this.daodi;
    }

    public void setDaodi(int v) {
        this.daodi = v;
    }

    public int getDefaultBattleEp() {
        return this.DefaultBattleEp;
    }

    public void setDefaultBattleEp(int v) {
        this.DefaultBattleEp = v;
    }

    public int getMaxSp() {
        return this.MaxSp;
    }

    public void setMaxSp(int v) {
        this.MaxSp = v;
    }

    public int getDefaultBattleSp() {
        return this.DefaultBattleSp;
    }

    public void setDefaultBattleSp(int v) {
        this.DefaultBattleSp = v;
    }

    public double getHpMaxAttackFactor() {
        return this.hpMaxAttackFactor;
    }

    public void setHpMaxAttackFactor(double v) {
        this.hpMaxAttackFactor = v;
    }

    public double getHpMaxFactor() {
        return this.hpMaxFactor;
    }

    public void setHpMaxFactor(double v) {
        this.hpMaxFactor = v;
    }

    public double getHpMaxConstant() {
        return this.hpMaxConstant;
    }

    public void setHpMaxConstant(double v) {
        this.hpMaxConstant = v;
    }

    public double getMpMaxFactor() {
        return this.mpMaxFactor;
    }

    public void setMpMaxFactor(double v) {
        this.mpMaxFactor = v;
    }

    public double getMpMaxConstant() {
        return this.mpMaxConstant;
    }

    public void setMpMaxConstant(double v) {
        this.mpMaxConstant = v;
    }

    public double getAttackFactor() {
        return this.attackFactor;
    }

    public void setAttackFactor(double v) {
        this.attackFactor = v;
    }

    public double getAttackConstant() {
        return this.attackConstant;
    }

    public void setAttackConstant(double v) {
        this.attackConstant = v;
    }

    public double getDefFactor() {
        return this.defFactor;
    }

    public void setDefFactor(double v) {
        this.defFactor = v;
    }

    public double getDefConstant() {
        return this.defConstant;
    }

    public void setDefConstant(double v) {
        this.defConstant = v;
    }

    public double getMagicattFactor() {
        return this.magicattFactor;
    }

    public void setMagicattFactor(double v) {
        this.magicattFactor = v;
    }

    public double getMagicattConstant() {
        return this.magicattConstant;
    }

    public void setMagicattConstant(double v) {
        this.magicattConstant = v;
    }

    public double getMagicDefFactor() {
        return this.magicDefFactor;
    }

    public void setMagicDefFactor(double v) {
        this.magicDefFactor = v;
    }

    public double getMagicDefConstant() {
        return this.magicDefConstant;
    }

    public void setMagicDefConstant(double v) {
        this.magicDefConstant = v;
    }

    public double getAttallFactor() {
        return this.attallFactor;
    }

    public void setAttallFactor(double v) {
        this.attallFactor = v;
    }

    public double getAttallConstant() {
        return this.attallConstant;
    }

    public void setAttallConstant(double v) {
        this.attallConstant = v;
    }

    public double getSpeedFactor() {
        return this.speedFactor;
    }

    public void setSpeedFactor(double v) {
        this.speedFactor = v;
    }

    public double getSpeedConstant() {
        return this.speedConstant;
    }

    public void setSpeedConstant(double v) {
        this.speedConstant = v;
    }

    public double getMedicalFactor() {
        return this.medicalFactor;
    }

    public void setMedicalFactor(double v) {
        this.medicalFactor = v;
    }

    public double getMedicalConstant() {
        return this.medicalConstant;
    }

    public void setMedicalConstant(double v) {
        this.medicalConstant = v;
    }

    public double getSealhitFactor() {
        return this.sealhitFactor;
    }

    public void setSealhitFactor(double v) {
        this.sealhitFactor = v;
    }

    public double getSealhitConstant() {
        return this.sealhitConstant;
    }

    public void setSealhitConstant(double v) {
        this.sealhitConstant = v;
    }

    public double getUnsealFactor() {
        return this.unsealFactor;
    }

    public void setUnsealFactor(double v) {
        this.unsealFactor = v;
    }

    public double getUnsealConstant() {
        return this.unsealConstant;
    }

    public void setUnsealConstant(double v) {
        this.unsealConstant = v;
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
