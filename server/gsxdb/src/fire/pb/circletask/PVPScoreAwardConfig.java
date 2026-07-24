//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class PVPScoreAwardConfig implements ConvMain.Checkable, Comparable<PVPScoreAwardConfig> {
    public int id = 0;
    public int score = 0;
    public int score2 = 0;
    public int win = 0;
    public int lose = 0;
    public int adwin = 0;
    public int adlose = 0;
    public int diswin = 0;
    public int dislose = 0;

    public int compareTo(PVPScoreAwardConfig o) {
        return this.id - o.id;
    }

    public PVPScoreAwardConfig() {
    }

    public PVPScoreAwardConfig(PVPScoreAwardConfig arg) {
        this.id = arg.id;
        this.score = arg.score;
        this.score2 = arg.score2;
        this.win = arg.win;
        this.lose = arg.lose;
        this.adwin = arg.adwin;
        this.adlose = arg.adlose;
        this.diswin = arg.diswin;
        this.dislose = arg.dislose;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getScore() {
        return this.score;
    }

    public void setScore(int v) {
        this.score = v;
    }

    public int getScore2() {
        return this.score2;
    }

    public void setScore2(int v) {
        this.score2 = v;
    }

    public int getWin() {
        return this.win;
    }

    public void setWin(int v) {
        this.win = v;
    }

    public int getLose() {
        return this.lose;
    }

    public void setLose(int v) {
        this.lose = v;
    }

    public int getAdwin() {
        return this.adwin;
    }

    public void setAdwin(int v) {
        this.adwin = v;
    }

    public int getAdlose() {
        return this.adlose;
    }

    public void setAdlose(int v) {
        this.adlose = v;
    }

    public int getDiswin() {
        return this.diswin;
    }

    public void setDiswin(int v) {
        this.diswin = v;
    }

    public int getDislose() {
        return this.dislose;
    }

    public void setDislose(int v) {
        this.dislose = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
