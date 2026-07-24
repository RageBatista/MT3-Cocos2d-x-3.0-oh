//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcGuaJi implements ConvMain.Checkable, Comparable<SNpcGuaJi> {
    public int id = 0;
    public String mapid = null;
    public String npcs = null;
    public int actid = 0;
    public int awardCnt = 0;

    public int compareTo(SNpcGuaJi var1) {
        return this.id - var1.id;
    }

    public SNpcGuaJi() {
    }

    public SNpcGuaJi(SNpcGuaJi var1) {
        this.id = var1.id;
        this.mapid = var1.mapid;
        this.npcs = var1.npcs;
        this.actid = var1.actid;
        this.awardCnt = var1.awardCnt;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> var1) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public String getMapid() {
        return this.mapid;
    }

    public void setMapid(String var1) {
        this.mapid = var1;
    }

    public String getNpcs() {
        return this.npcs;
    }

    public void setNpcs(String var1) {
        this.npcs = var1;
    }

    public int getActid() {
        return this.actid;
    }

    public void setActid(int var1) {
        this.actid = var1;
    }

    public int getAwardCnt() {
        return this.awardCnt;
    }

    public void setAwardCnt(int var1) {
        this.awardCnt = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
