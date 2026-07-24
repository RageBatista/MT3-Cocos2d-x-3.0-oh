//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class Saddpointchange implements ConvMain.Checkable, Comparable<Saddpointchange> {
    public int id = 0;
    public int consume = 0;

    public int compareTo(Saddpointchange o) {
        return this.id - o.id;
    }

    public Saddpointchange() {
    }

    public Saddpointchange(Saddpointchange arg) {
        this.id = arg.id;
        this.consume = arg.consume;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getConsume() {
        return this.consume;
    }

    public void setConsume(int v) {
        this.consume = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
