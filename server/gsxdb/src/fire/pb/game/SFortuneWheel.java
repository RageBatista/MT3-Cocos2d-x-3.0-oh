//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SFortuneWheel implements ConvMain.Checkable, Comparable<SFortuneWheel> {
    public int id = 0;
    public ArrayList<String> cards;

    public int compareTo(SFortuneWheel o) {
        return this.id - o.id;
    }

    public SFortuneWheel() {
    }

    public SFortuneWheel(SFortuneWheel arg) {
        this.id = arg.id;
        this.cards = arg.cards;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<String> getCards() {
        return this.cards;
    }

    public void setCards(ArrayList<String> v) {
        this.cards = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
