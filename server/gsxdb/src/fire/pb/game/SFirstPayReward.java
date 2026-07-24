//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SFirstPayReward implements ConvMain.Checkable, Comparable<SFirstPayReward> {
    public int id = 0;
    public ArrayList<FirstPayGiftData> rewardmap;

    public int compareTo(SFirstPayReward o) {
        return this.id - o.id;
    }

    public SFirstPayReward() {
    }

    public SFirstPayReward(SFirstPayReward arg) {
        this.id = arg.id;
        this.rewardmap = arg.rewardmap;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<FirstPayGiftData> getRewardmap() {
        return this.rewardmap;
    }

    public void setRewardmap(ArrayList<FirstPayGiftData> v) {
        this.rewardmap = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
