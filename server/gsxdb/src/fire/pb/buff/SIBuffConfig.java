//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.buff;

import java.util.Map;
import mytools.ConvMain;

public class SIBuffConfig implements ConvMain.Checkable, Comparable<SIBuffConfig> {
    public int id = 0;
    public String name = null;
    public int bufftype = 0;
    public String classname = null;
    public int buffclass = 0;
    public String targetBuffs = null;
    public String effects = null;

    public int compareTo(SIBuffConfig o) {
        return this.id - o.id;
    }

    public SIBuffConfig() {
    }

    public SIBuffConfig(SIBuffConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.bufftype = arg.bufftype;
        this.classname = arg.classname;
        this.buffclass = arg.buffclass;
        this.targetBuffs = arg.targetBuffs;
        this.effects = arg.effects;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getBufftype() {
        return this.bufftype;
    }

    public void setBufftype(int v) {
        this.bufftype = v;
    }

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    public int getBuffclass() {
        return this.buffclass;
    }

    public void setBuffclass(int v) {
        this.buffclass = v;
    }

    public String getTargetBuffs() {
        return this.targetBuffs;
    }

    public void setTargetBuffs(String v) {
        this.targetBuffs = v;
    }

    public String getEffects() {
        return this.effects;
    }

    public void setEffects(String v) {
        this.effects = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
