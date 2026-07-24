//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class feixingqi implements ConvMain.Checkable, Comparable<feixingqi> {
    public int id = 0;
    public int map = 0;
    public int mapx = 0;
    public int mapy = 0;

    public int compareTo(feixingqi o) {
        return this.id - o.id;
    }

    public feixingqi() {
    }

    public feixingqi(feixingqi arg) {
        this.id = arg.id;
        this.map = arg.map;
        this.mapx = arg.mapx;
        this.mapy = arg.mapy;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMap() {
        return this.map;
    }

    public void setMap(int v) {
        this.map = v;
    }

    public int getMapx() {
        return this.mapx;
    }

    public void setMapx(int v) {
        this.mapx = v;
    }

    public int getMapy() {
        return this.mapy;
    }

    public void setMapy(int v) {
        this.mapy = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
