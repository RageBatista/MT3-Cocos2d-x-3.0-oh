//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class Sxytaozhuang implements ConvMain.Checkable, Comparable<Sxytaozhuang> {
    public int id = 0;
    public int equipbuff = 0;
    public String buffid = null;
    public int skillid = 0;

    public int compareTo(Sxytaozhuang o) {
        return this.id - o.id;
    }

    public Sxytaozhuang() {
    }

    public Sxytaozhuang(Sxytaozhuang arg) {
        this.id = arg.id;
        this.equipbuff = arg.equipbuff;
        this.buffid = arg.buffid;
        this.skillid = arg.skillid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getEquipbuff() {
        return this.equipbuff;
    }

    public void setEquipbuff(int v) {
        this.equipbuff = v;
    }

    public String getBuffid() {
        return this.buffid;
    }

    public void setBuffid(String v) {
        this.buffid = v;
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
