//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.Map;
import mytools.ConvMain;

public class SBingFengJiangLiCfg implements ConvMain.Checkable, Comparable<SBingFengJiangLiCfg> {
    public int id = 0;
    public int rankid = 0;
    public int fubenid = 0;
    public int ranklv = 0;

    public int compareTo(SBingFengJiangLiCfg o) {
        return this.id - o.id;
    }

    public SBingFengJiangLiCfg() {
    }

    public SBingFengJiangLiCfg(SBingFengJiangLiCfg arg) {
        this.id = arg.id;
        this.rankid = arg.rankid;
        this.fubenid = arg.fubenid;
        this.ranklv = arg.ranklv;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getRankid() {
        return this.rankid;
    }

    public void setRankid(int v) {
        this.rankid = v;
    }

    public int getFubenid() {
        return this.fubenid;
    }

    public void setFubenid(int v) {
        this.fubenid = v;
    }

    public int getRanklv() {
        return this.ranklv;
    }

    public void setRanklv(int v) {
        this.ranklv = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
