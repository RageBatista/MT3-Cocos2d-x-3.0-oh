//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class SLeaderAward implements ConvMain.Checkable, Comparable<SLeaderAward> {
    public int id = 0;
    public int awardId = 0;

    public int compareTo(SLeaderAward o) {
        return this.id - o.id;
    }

    public SLeaderAward() {
    }

    public SLeaderAward(SLeaderAward arg) {
        this.id = arg.id;
        this.awardId = arg.awardId;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getAwardId() {
        return this.awardId;
    }

    public void setAwardId(int v) {
        this.awardId = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
