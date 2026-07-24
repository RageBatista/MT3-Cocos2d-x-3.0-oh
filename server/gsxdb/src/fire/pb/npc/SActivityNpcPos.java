//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SActivityNpcPos implements ConvMain.Checkable, Comparable<SActivityNpcPos> {
    public int id = 0;
    public ArrayList<SNpcPos> npcPoses;

    public int compareTo(SActivityNpcPos o) {
        return this.id - o.id;
    }

    public SActivityNpcPos() {
    }

    public SActivityNpcPos(SActivityNpcPos arg) {
        this.id = arg.id;
        this.npcPoses = arg.npcPoses;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<SNpcPos> getNpcPoses() {
        return this.npcPoses;
    }

    public void setNpcPoses(ArrayList<SNpcPos> v) {
        this.npcPoses = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
