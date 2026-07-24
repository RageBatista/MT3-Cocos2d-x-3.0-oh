//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class SCircTaskMonsterConfig implements ConvMain.Checkable, Comparable<SCircTaskMonsterConfig> {
    public int id = 0;
    public int group = 0;
    public String mapids = null;
    public String battleinfo = null;

    public int compareTo(SCircTaskMonsterConfig o) {
        return this.id - o.id;
    }

    public SCircTaskMonsterConfig() {
    }

    public SCircTaskMonsterConfig(SCircTaskMonsterConfig arg) {
        this.id = arg.id;
        this.group = arg.group;
        this.mapids = arg.mapids;
        this.battleinfo = arg.battleinfo;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getGroup() {
        return this.group;
    }

    public void setGroup(int v) {
        this.group = v;
    }

    public String getMapids() {
        return this.mapids;
    }

    public void setMapids(String v) {
        this.mapids = v;
    }

    public String getBattleinfo() {
        return this.battleinfo;
    }

    public void setBattleinfo(String v) {
        this.battleinfo = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
