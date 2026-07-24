//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.activity;

import java.util.Map;

public class SFestivalConf4D extends FestivalConf {
    public int compareTo(SFestivalConf4D o) {
        return this.id - o.id;
    }

    public SFestivalConf4D(FestivalConf arg) {
        super(arg);
    }

    public SFestivalConf4D() {
    }

    public SFestivalConf4D(SFestivalConf4D arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
