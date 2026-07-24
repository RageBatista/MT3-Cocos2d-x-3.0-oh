//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SFestivalGift implements ConvMain.Checkable, Comparable<SFestivalGift> {
    public int id = 0;
    public String time = null;
    public String name = null;
    public int awardid = 0;
    public int sourceid = 0;

    public int compareTo(SFestivalGift o) {
        return this.id - o.id;
    }

    public SFestivalGift() {
    }

    public SFestivalGift(SFestivalGift arg) {
        this.id = arg.id;
        this.time = arg.time;
        this.name = arg.name;
        this.awardid = arg.awardid;
        this.sourceid = arg.sourceid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getTime() {
        return this.time;
    }

    public void setTime(String v) {
        this.time = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getAwardid() {
        return this.awardid;
    }

    public void setAwardid(int v) {
        this.awardid = v;
    }

    public int getSourceid() {
        return this.sourceid;
    }

    public void setSourceid(int v) {
        this.sourceid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
