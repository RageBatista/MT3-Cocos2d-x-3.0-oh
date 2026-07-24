//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SBindTelAward implements ConvMain.Checkable, Comparable<SBindTelAward> {
    public int id = 0;
    public ArrayList<BindTelAwardData> rewardvec;

    public int compareTo(SBindTelAward o) {
        return this.id - o.id;
    }

    public SBindTelAward() {
    }

    public SBindTelAward(SBindTelAward arg) {
        this.id = arg.id;
        this.rewardvec = arg.rewardvec;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<BindTelAwardData> getRewardvec() {
        return this.rewardvec;
    }

    public void setRewardvec(ArrayList<BindTelAwardData> v) {
        this.rewardvec = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
