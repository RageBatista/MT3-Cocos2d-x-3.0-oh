//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import java.util.Map;
import mytools.ConvMain;

public class FriendGiveGift implements ConvMain.Checkable, Comparable<FriendGiveGift> {
    public int id = 0;
    public int oppositeSexFriendlyDegrees = 0;
    public int sameSexFriendlyDegrees = 0;

    public int compareTo(FriendGiveGift o) {
        return this.id - o.id;
    }

    public FriendGiveGift() {
    }

    public FriendGiveGift(FriendGiveGift arg) {
        this.id = arg.id;
        this.oppositeSexFriendlyDegrees = arg.oppositeSexFriendlyDegrees;
        this.sameSexFriendlyDegrees = arg.sameSexFriendlyDegrees;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getOppositeSexFriendlyDegrees() {
        return this.oppositeSexFriendlyDegrees;
    }

    public void setOppositeSexFriendlyDegrees(int v) {
        this.oppositeSexFriendlyDegrees = v;
    }

    public int getSameSexFriendlyDegrees() {
        return this.sameSexFriendlyDegrees;
    }

    public void setSameSexFriendlyDegrees(int v) {
        this.sameSexFriendlyDegrees = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
