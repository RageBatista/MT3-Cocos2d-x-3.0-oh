//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SNuqiget implements ConvMain.Checkable, Comparable<SNuqiget> {
    public int id = 0;
    public int hurtmin = 0;
    public int hurtmax = 0;
    public int nuqiget = 0;

    public int compareTo(SNuqiget o) {
        return this.id - o.id;
    }

    public SNuqiget() {
    }

    public SNuqiget(SNuqiget arg) {
        this.id = arg.id;
        this.hurtmin = arg.hurtmin;
        this.hurtmax = arg.hurtmax;
        this.nuqiget = arg.nuqiget;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getHurtmin() {
        return this.hurtmin;
    }

    public void setHurtmin(int v) {
        this.hurtmin = v;
    }

    public int getHurtmax() {
        return this.hurtmax;
    }

    public void setHurtmax(int v) {
        this.hurtmax = v;
    }

    public int getNuqiget() {
        return this.nuqiget;
    }

    public void setNuqiget(int v) {
        this.nuqiget = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
