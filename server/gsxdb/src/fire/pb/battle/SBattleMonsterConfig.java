//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SBattleMonsterConfig implements ConvMain.Checkable, Comparable<SBattleMonsterConfig> {
    public int id = 0;
    public int teamsize = 0;
    public int 怪物数目 = 0;
    public int 普通怪数目 = 0;
    public int 头领数目 = 0;
    public int 出现概率 = 0;

    public int compareTo(SBattleMonsterConfig o) {
        return this.id - o.id;
    }

    public SBattleMonsterConfig() {
    }

    public SBattleMonsterConfig(SBattleMonsterConfig arg) {
        this.id = arg.id;
        this.teamsize = arg.teamsize;
        this.怪物数目 = arg.怪物数目;
        this.普通怪数目 = arg.普通怪数目;
        this.头领数目 = arg.头领数目;
        this.出现概率 = arg.出现概率;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getTeamsize() {
        return this.teamsize;
    }

    public void setTeamsize(int v) {
        this.teamsize = v;
    }

    public int get怪物数目() {
        return this.怪物数目;
    }

    public void set怪物数目(int v) {
        this.怪物数目 = v;
    }

    public int get普通怪数目() {
        return this.普通怪数目;
    }

    public void set普通怪数目(int v) {
        this.普通怪数目 = v;
    }

    public int get头领数目() {
        return this.头领数目;
    }

    public void set头领数目(int v) {
        this.头领数目 = v;
    }

    public int get出现概率() {
        return this.出现概率;
    }

    public void set出现概率(int v) {
        this.出现概率 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
