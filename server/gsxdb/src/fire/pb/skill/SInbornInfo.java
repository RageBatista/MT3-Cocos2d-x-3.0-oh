//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInbornInfo implements ConvMain.Checkable, Comparable<SInbornInfo> {
    public int id = 0;
    public String skillname = null;
    public int school = 0;
    public boolean isMain = false;
    public boolean isnbskill = false;
    public int maxLevel = 0;
    public String dependInborn = null;
    public int dependLevel = 0;
    public String nbskilldependLevel = null;
    public int consumerule = 0;
    public ArrayList<Integer> pointToSkillList;

    public int compareTo(SInbornInfo o) {
        return this.id - o.id;
    }

    public SInbornInfo() {
    }

    public SInbornInfo(SInbornInfo arg) {
        this.id = arg.id;
        this.skillname = arg.skillname;
        this.school = arg.school;
        this.isMain = arg.isMain;
        this.isnbskill = arg.isnbskill;
        this.maxLevel = arg.maxLevel;
        this.dependInborn = arg.dependInborn;
        this.dependLevel = arg.dependLevel;
        this.nbskilldependLevel = arg.nbskilldependLevel;
        this.consumerule = arg.consumerule;
        this.pointToSkillList = arg.pointToSkillList;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getSkillname() {
        return this.skillname;
    }

    public void setSkillname(String v) {
        this.skillname = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public boolean getIsMain() {
        return this.isMain;
    }

    public void setIsMain(boolean v) {
        this.isMain = v;
    }

    public boolean getIsnbskill() {
        return this.isnbskill;
    }

    public void setIsnbskill(boolean v) {
        this.isnbskill = v;
    }

    public int getMaxLevel() {
        return this.maxLevel;
    }

    public void setMaxLevel(int v) {
        this.maxLevel = v;
    }

    public String getDependInborn() {
        return this.dependInborn;
    }

    public void setDependInborn(String v) {
        this.dependInborn = v;
    }

    public int getDependLevel() {
        return this.dependLevel;
    }

    public void setDependLevel(int v) {
        this.dependLevel = v;
    }

    public String getNbskilldependLevel() {
        return this.nbskilldependLevel;
    }

    public void setNbskilldependLevel(String v) {
        this.nbskilldependLevel = v;
    }

    public int getConsumerule() {
        return this.consumerule;
    }

    public void setConsumerule(int v) {
        this.consumerule = v;
    }

    public ArrayList<Integer> getPointToSkillList() {
        return this.pointToSkillList;
    }

    public void setPointToSkillList(ArrayList<Integer> v) {
        this.pointToSkillList = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
