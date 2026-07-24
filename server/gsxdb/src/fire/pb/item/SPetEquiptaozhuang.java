//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SPetEquiptaozhuang implements ConvMain.Checkable, Comparable<SPetEquiptaozhuang> {
    public int id = 0;
    public int skill = 0;
    public int jilv = 0;
    public int dzjilv = 0;

    public int compareTo(SPetEquiptaozhuang o) {
        return this.id - o.id;
    }

    public SPetEquiptaozhuang() {
    }

    public SPetEquiptaozhuang(SPetEquiptaozhuang arg) {
        this.id = arg.id;
        this.skill = arg.skill;
        this.jilv = arg.jilv;
        this.dzjilv = arg.dzjilv;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSkill() {
        return this.skill;
    }

    public void setSkill(int v) {
        this.skill = v;
    }

    public int getJilv() {
        return this.jilv;
    }

    public void setJilv(int v) {
        this.jilv = v;
    }

    public int getDzjilv() {
        return this.dzjilv;
    }

    public void setDzjilv(int v) {
        this.dzjilv = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
