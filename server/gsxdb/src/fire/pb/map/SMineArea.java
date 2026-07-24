//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SMineArea implements ConvMain.Checkable, Comparable<SMineArea> {
    public int id = 0;
    public int level = 0;
    public int maxLevel = 0;
    public int environment = 0;
    public String babyrate = null;
    public String bossrate = null;
    public String specialrate = null;
    public String commonrate = null;
    public String specialevents = null;
    public ArrayList<Integer> pet;
    public ArrayList<Integer> petrate;
    public ArrayList<Integer> leader;
    public ArrayList<Integer> leaderrate;
    public ArrayList<Integer> monster;
    public ArrayList<Integer> monsterrate;
    public int lootid = 0;
    public int shared = 0;
    public int bossbattleid = 0;

    public int compareTo(SMineArea o) {
        return this.id - o.id;
    }

    public SMineArea() {
    }

    public SMineArea(SMineArea arg) {
        this.id = arg.id;
        this.level = arg.level;
        this.maxLevel = arg.maxLevel;
        this.environment = arg.environment;
        this.babyrate = arg.babyrate;
        this.bossrate = arg.bossrate;
        this.specialrate = arg.specialrate;
        this.commonrate = arg.commonrate;
        this.specialevents = arg.specialevents;
        this.pet = arg.pet;
        this.petrate = arg.petrate;
        this.leader = arg.leader;
        this.leaderrate = arg.leaderrate;
        this.monster = arg.monster;
        this.monsterrate = arg.monsterrate;
        this.lootid = arg.lootid;
        this.shared = arg.shared;
        this.bossbattleid = arg.bossbattleid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public int getMaxLevel() {
        return this.maxLevel;
    }

    public void setMaxLevel(int v) {
        this.maxLevel = v;
    }

    public int getEnvironment() {
        return this.environment;
    }

    public void setEnvironment(int v) {
        this.environment = v;
    }

    public String getBabyrate() {
        return this.babyrate;
    }

    public void setBabyrate(String v) {
        this.babyrate = v;
    }

    public String getBossrate() {
        return this.bossrate;
    }

    public void setBossrate(String v) {
        this.bossrate = v;
    }

    public String getSpecialrate() {
        return this.specialrate;
    }

    public void setSpecialrate(String v) {
        this.specialrate = v;
    }

    public String getCommonrate() {
        return this.commonrate;
    }

    public void setCommonrate(String v) {
        this.commonrate = v;
    }

    public String getSpecialevents() {
        return this.specialevents;
    }

    public void setSpecialevents(String v) {
        this.specialevents = v;
    }

    public ArrayList<Integer> getPet() {
        return this.pet;
    }

    public void setPet(ArrayList<Integer> v) {
        this.pet = v;
    }

    public ArrayList<Integer> getPetrate() {
        return this.petrate;
    }

    public void setPetrate(ArrayList<Integer> v) {
        this.petrate = v;
    }

    public ArrayList<Integer> getLeader() {
        return this.leader;
    }

    public void setLeader(ArrayList<Integer> v) {
        this.leader = v;
    }

    public ArrayList<Integer> getLeaderrate() {
        return this.leaderrate;
    }

    public void setLeaderrate(ArrayList<Integer> v) {
        this.leaderrate = v;
    }

    public ArrayList<Integer> getMonster() {
        return this.monster;
    }

    public void setMonster(ArrayList<Integer> v) {
        this.monster = v;
    }

    public ArrayList<Integer> getMonsterrate() {
        return this.monsterrate;
    }

    public void setMonsterrate(ArrayList<Integer> v) {
        this.monsterrate = v;
    }

    public int getLootid() {
        return this.lootid;
    }

    public void setLootid(int v) {
        this.lootid = v;
    }

    public int getShared() {
        return this.shared;
    }

    public void setShared(int v) {
        this.shared = v;
    }

    public int getBossbattleid() {
        return this.bossbattleid;
    }

    public void setBossbattleid(int v) {
        this.bossbattleid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
