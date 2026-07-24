//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class Sdongtaifuwu implements ConvMain.Checkable, Comparable<Sdongtaifuwu> {
    public int id = 0;
    public int npcid = 0;
    public int fuwuid = 0;
    public String kaishitime = null;
    public String jeishutime = null;

    public int compareTo(Sdongtaifuwu o) {
        return this.id - o.id;
    }

    public Sdongtaifuwu() {
    }

    public Sdongtaifuwu(Sdongtaifuwu arg) {
        this.id = arg.id;
        this.npcid = arg.npcid;
        this.fuwuid = arg.fuwuid;
        this.kaishitime = arg.kaishitime;
        this.jeishutime = arg.jeishutime;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNpcid() {
        return this.npcid;
    }

    public void setNpcid(int v) {
        this.npcid = v;
    }

    public int getFuwuid() {
        return this.fuwuid;
    }

    public void setFuwuid(int v) {
        this.fuwuid = v;
    }

    public String getKaishitime() {
        return this.kaishitime;
    }

    public void setKaishitime(String v) {
        this.kaishitime = v;
    }

    public String getJeishutime() {
        return this.jeishutime;
    }

    public void setJeishutime(String v) {
        this.jeishutime = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
