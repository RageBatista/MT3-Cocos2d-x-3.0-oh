//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class ZhaoHuanLingWithEvent implements ConvMain.Checkable, Comparable<ZhaoHuanLingWithEvent> {
    public int id = 0;
    public int eventId = 0;

    public int compareTo(ZhaoHuanLingWithEvent var1) {
        return this.id - var1.id;
    }

    public ZhaoHuanLingWithEvent() {
    }

    public ZhaoHuanLingWithEvent(ZhaoHuanLingWithEvent var1) {
        this.id = var1.id;
        this.eventId = var1.eventId;
    }

    public void checkValid(Map<String, Map<Integer, ?>> var1) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public int getEventId() {
        return this.eventId;
    }

    public void setEventId(int var1) {
        this.eventId = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
