//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SLandPingJi implements ConvMain.Checkable, Comparable<SLandPingJi> {
    public int id = 0;
    public String level = null;
    public int minround = 0;
    public int maxround = 0;
    public int exppersent = 0;
    public String tubiaolujing = null;

    public int compareTo(SLandPingJi o) {
        return this.id - o.id;
    }

    public SLandPingJi() {
    }

    public SLandPingJi(SLandPingJi arg) {
        this.id = arg.id;
        this.level = arg.level;
        this.minround = arg.minround;
        this.maxround = arg.maxround;
        this.exppersent = arg.exppersent;
        this.tubiaolujing = arg.tubiaolujing;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getLevel() {
        return this.level;
    }

    public void setLevel(String v) {
        this.level = v;
    }

    public int getMinround() {
        return this.minround;
    }

    public void setMinround(int v) {
        this.minround = v;
    }

    public int getMaxround() {
        return this.maxround;
    }

    public void setMaxround(int v) {
        this.maxround = v;
    }

    public int getExppersent() {
        return this.exppersent;
    }

    public void setExppersent(int v) {
        this.exppersent = v;
    }

    public String getTubiaolujing() {
        return this.tubiaolujing;
    }

    public void setTubiaolujing(String v) {
        this.tubiaolujing = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
