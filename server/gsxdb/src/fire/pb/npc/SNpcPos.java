//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcPos implements ConvMain.Checkable {
    public int npcid = 0;
    public String npcName = null;
    public int npcMap = 0;
    public int npcPosx = 0;
    public int npcPosy = 0;

    public SNpcPos() {
    }

    public SNpcPos(SNpcPos arg) {
        this.npcid = arg.npcid;
        this.npcName = arg.npcName;
        this.npcMap = arg.npcMap;
        this.npcPosx = arg.npcPosx;
        this.npcPosy = arg.npcPosy;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getNpcid() {
        return this.npcid;
    }

    public void setNpcid(int v) {
        this.npcid = v;
    }

    public String getNpcName() {
        return this.npcName;
    }

    public void setNpcName(String v) {
        this.npcName = v;
    }

    public int getNpcMap() {
        return this.npcMap;
    }

    public void setNpcMap(int v) {
        this.npcMap = v;
    }

    public int getNpcPosx() {
        return this.npcPosx;
    }

    public void setNpcPosx(int v) {
        this.npcPosx = v;
    }

    public int getNpcPosy() {
        return this.npcPosy;
    }

    public void setNpcPosy(int v) {
        this.npcPosy = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
