//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class SItemToPos implements ConvMain.Checkable, Comparable<SItemToPos> {
    public int id = 0;
    public String mapList = null;
    public int mapRemotePos = 0;

    public int compareTo(SItemToPos o) {
        return this.id - o.id;
    }

    public SItemToPos() {
    }

    public SItemToPos(SItemToPos arg) {
        this.id = arg.id;
        this.mapList = arg.mapList;
        this.mapRemotePos = arg.mapRemotePos;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getMapList() {
        return this.mapList;
    }

    public void setMapList(String v) {
        this.mapList = v;
    }

    public int getMapRemotePos() {
        return this.mapRemotePos;
    }

    public void setMapRemotePos(int v) {
        this.mapRemotePos = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
