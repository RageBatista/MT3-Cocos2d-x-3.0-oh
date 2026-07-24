//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInbornConsume implements ConvMain.Checkable, Comparable<SInbornConsume> {
    public int id = 0;
    public ArrayList<InbornConsume> consumes;

    public int compareTo(SInbornConsume o) {
        return this.id - o.id;
    }

    public SInbornConsume() {
    }

    public SInbornConsume(SInbornConsume arg) {
        this.id = arg.id;
        this.consumes = arg.consumes;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<InbornConsume> getConsumes() {
        return this.consumes;
    }

    public void setConsumes(ArrayList<InbornConsume> v) {
        this.consumes = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
