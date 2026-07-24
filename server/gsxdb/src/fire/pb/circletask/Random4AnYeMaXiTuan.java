//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class Random4AnYeMaXiTuan implements ConvMain.Checkable, Comparable<Random4AnYeMaXiTuan> {
    public int id = 0;
    public int levelmin = 0;
    public int levelmax = 0;
    public int roundmin = 0;
    public int roundmax = 0;
    public String questrate = null;

    public int compareTo(Random4AnYeMaXiTuan o) {
        return this.id - o.id;
    }

    public Random4AnYeMaXiTuan() {
    }

    public Random4AnYeMaXiTuan(Random4AnYeMaXiTuan arg) {
        this.id = arg.id;
        this.levelmin = arg.levelmin;
        this.levelmax = arg.levelmax;
        this.roundmin = arg.roundmin;
        this.roundmax = arg.roundmax;
        this.questrate = arg.questrate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevelmin() {
        return this.levelmin;
    }

    public void setLevelmin(int v) {
        this.levelmin = v;
    }

    public int getLevelmax() {
        return this.levelmax;
    }

    public void setLevelmax(int v) {
        this.levelmax = v;
    }

    public int getRoundmin() {
        return this.roundmin;
    }

    public void setRoundmin(int v) {
        this.roundmin = v;
    }

    public int getRoundmax() {
        return this.roundmax;
    }

    public void setRoundmax(int v) {
        this.roundmax = v;
    }

    public String getQuestrate() {
        return this.questrate;
    }

    public void setQuestrate(String v) {
        this.questrate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
