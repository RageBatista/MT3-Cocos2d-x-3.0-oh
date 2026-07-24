//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SHeroBaseInfo implements ConvMain.Checkable, Comparable<SHeroBaseInfo> {
    public int id = 0;
    public String name = null;
    public int type = 0;
    public int school = 0;
    public double bodytype = (double)0.0F;
    public int shapeid = 0;
    public int headid = 0;
    public int creater_give = 0;
    public int life = 0;
    public int magic = 0;
    public int phyatk = 0;
    public int phydef = 0;
    public int magatk = 0;
    public int magdef = 0;
    public double speed = (double)0.0F;
    public int treat = 0;
    public int hit = 0;
    public double resistance = (double)0.0F;
    public double life_growup = (double)0.0F;
    public double magic_growup = (double)0.0F;
    public double phyatk_growup = (double)0.0F;
    public double phydef_growup = (double)0.0F;
    public double magatk_growup = (double)0.0F;
    public double magdef_growup = (double)0.0F;
    public double speed_growup = (double)0.0F;
    public double treat_growup = (double)0.0F;
    public double hit_growup = (double)0.0F;
    public double resistance_growup = (double)0.0F;
    public ArrayList<Integer> battle_ai;
    public ArrayList<Integer> skillid;
    public int first_skill = 0;
    public ArrayList<Integer> day7_money;
    public ArrayList<Integer> day30_money;
    public ArrayList<Integer> forever_money;
    public double levelfactor = (double)0.0F;
    public int levelconstant = 0;

    public int compareTo(SHeroBaseInfo o) {
        return this.id - o.id;
    }

    public SHeroBaseInfo() {
    }

    public SHeroBaseInfo(SHeroBaseInfo arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.type = arg.type;
        this.school = arg.school;
        this.bodytype = arg.bodytype;
        this.shapeid = arg.shapeid;
        this.headid = arg.headid;
        this.creater_give = arg.creater_give;
        this.life = arg.life;
        this.magic = arg.magic;
        this.phyatk = arg.phyatk;
        this.phydef = arg.phydef;
        this.magatk = arg.magatk;
        this.magdef = arg.magdef;
        this.speed = arg.speed;
        this.treat = arg.treat;
        this.hit = arg.hit;
        this.resistance = arg.resistance;
        this.life_growup = arg.life_growup;
        this.magic_growup = arg.magic_growup;
        this.phyatk_growup = arg.phyatk_growup;
        this.phydef_growup = arg.phydef_growup;
        this.magatk_growup = arg.magatk_growup;
        this.magdef_growup = arg.magdef_growup;
        this.speed_growup = arg.speed_growup;
        this.treat_growup = arg.treat_growup;
        this.hit_growup = arg.hit_growup;
        this.resistance_growup = arg.resistance_growup;
        this.battle_ai = arg.battle_ai;
        this.skillid = arg.skillid;
        this.first_skill = arg.first_skill;
        this.day7_money = arg.day7_money;
        this.day30_money = arg.day30_money;
        this.forever_money = arg.forever_money;
        this.levelfactor = arg.levelfactor;
        this.levelconstant = arg.levelconstant;
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

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public double getBodytype() {
        return this.bodytype;
    }

    public void setBodytype(double v) {
        this.bodytype = v;
    }

    public int getShapeid() {
        return this.shapeid;
    }

    public void setShapeid(int v) {
        this.shapeid = v;
    }

    public int getHeadid() {
        return this.headid;
    }

    public void setHeadid(int v) {
        this.headid = v;
    }

    public int getCreater_give() {
        return this.creater_give;
    }

    public void setCreater_give(int v) {
        this.creater_give = v;
    }

    public int getLife() {
        return this.life;
    }

    public void setLife(int v) {
        this.life = v;
    }

    public int getMagic() {
        return this.magic;
    }

    public void setMagic(int v) {
        this.magic = v;
    }

    public int getPhyatk() {
        return this.phyatk;
    }

    public void setPhyatk(int v) {
        this.phyatk = v;
    }

    public int getPhydef() {
        return this.phydef;
    }

    public void setPhydef(int v) {
        this.phydef = v;
    }

    public int getMagatk() {
        return this.magatk;
    }

    public void setMagatk(int v) {
        this.magatk = v;
    }

    public int getMagdef() {
        return this.magdef;
    }

    public void setMagdef(int v) {
        this.magdef = v;
    }

    public double getSpeed() {
        return this.speed;
    }

    public void setSpeed(double v) {
        this.speed = v;
    }

    public int getTreat() {
        return this.treat;
    }

    public void setTreat(int v) {
        this.treat = v;
    }

    public int getHit() {
        return this.hit;
    }

    public void setHit(int v) {
        this.hit = v;
    }

    public double getResistance() {
        return this.resistance;
    }

    public void setResistance(double v) {
        this.resistance = v;
    }

    public double getLife_growup() {
        return this.life_growup;
    }

    public void setLife_growup(double v) {
        this.life_growup = v;
    }

    public double getMagic_growup() {
        return this.magic_growup;
    }

    public void setMagic_growup(double v) {
        this.magic_growup = v;
    }

    public double getPhyatk_growup() {
        return this.phyatk_growup;
    }

    public void setPhyatk_growup(double v) {
        this.phyatk_growup = v;
    }

    public double getPhydef_growup() {
        return this.phydef_growup;
    }

    public void setPhydef_growup(double v) {
        this.phydef_growup = v;
    }

    public double getMagatk_growup() {
        return this.magatk_growup;
    }

    public void setMagatk_growup(double v) {
        this.magatk_growup = v;
    }

    public double getMagdef_growup() {
        return this.magdef_growup;
    }

    public void setMagdef_growup(double v) {
        this.magdef_growup = v;
    }

    public double getSpeed_growup() {
        return this.speed_growup;
    }

    public void setSpeed_growup(double v) {
        this.speed_growup = v;
    }

    public double getTreat_growup() {
        return this.treat_growup;
    }

    public void setTreat_growup(double v) {
        this.treat_growup = v;
    }

    public double getHit_growup() {
        return this.hit_growup;
    }

    public void setHit_growup(double v) {
        this.hit_growup = v;
    }

    public double getResistance_growup() {
        return this.resistance_growup;
    }

    public void setResistance_growup(double v) {
        this.resistance_growup = v;
    }

    public ArrayList<Integer> getBattle_ai() {
        return this.battle_ai;
    }

    public void setBattle_ai(ArrayList<Integer> v) {
        this.battle_ai = v;
    }

    public ArrayList<Integer> getSkillid() {
        return this.skillid;
    }

    public void setSkillid(ArrayList<Integer> v) {
        this.skillid = v;
    }

    public int getFirst_skill() {
        return this.first_skill;
    }

    public void setFirst_skill(int v) {
        this.first_skill = v;
    }

    public ArrayList<Integer> getDay7_money() {
        return this.day7_money;
    }

    public void setDay7_money(ArrayList<Integer> v) {
        this.day7_money = v;
    }

    public ArrayList<Integer> getDay30_money() {
        return this.day30_money;
    }

    public void setDay30_money(ArrayList<Integer> v) {
        this.day30_money = v;
    }

    public ArrayList<Integer> getForever_money() {
        return this.forever_money;
    }

    public void setForever_money(ArrayList<Integer> v) {
        this.forever_money = v;
    }

    public double getLevelfactor() {
        return this.levelfactor;
    }

    public void setLevelfactor(double v) {
        this.levelfactor = v;
    }

    public int getLevelconstant() {
        return this.levelconstant;
    }

    public void setLevelconstant(int v) {
        this.levelconstant = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
