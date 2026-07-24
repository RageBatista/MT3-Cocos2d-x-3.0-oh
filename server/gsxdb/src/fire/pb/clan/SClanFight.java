//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanFight implements ConvMain.Checkable, Comparable<SClanFight> {
    public int id = 0;
    public String name = null;
    public int mapid = 0;
    public int x1 = 0;
    public int y1 = 0;
    public int x2 = 0;
    public int y2 = 0;
    public int outmapid = 0;
    public int outx1 = 0;
    public int outy1 = 0;

    public int compareTo(SClanFight o) {
        return this.id - o.id;
    }

    public SClanFight() {
    }

    public SClanFight(SClanFight arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.mapid = arg.mapid;
        this.x1 = arg.x1;
        this.y1 = arg.y1;
        this.x2 = arg.x2;
        this.y2 = arg.y2;
        this.outmapid = arg.outmapid;
        this.outx1 = arg.outx1;
        this.outy1 = arg.outy1;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getMapid() {
        return this.mapid;
    }

    public void setMapid(int v) {
        this.mapid = v;
    }

    public int getX1() {
        return this.x1;
    }

    public void setX1(int v) {
        this.x1 = v;
    }

    public int getY1() {
        return this.y1;
    }

    public void setY1(int v) {
        this.y1 = v;
    }

    public int getX2() {
        return this.x2;
    }

    public void setX2(int v) {
        this.x2 = v;
    }

    public int getY2() {
        return this.y2;
    }

    public void setY2(int v) {
        this.y2 = v;
    }

    public int getOutmapid() {
        return this.outmapid;
    }

    public void setOutmapid(int v) {
        this.outmapid = v;
    }

    public int getOutx1() {
        return this.outx1;
    }

    public void setOutx1(int v) {
        this.outx1 = v;
    }

    public int getOuty1() {
        return this.outy1;
    }

    public void setOuty1(int v) {
        this.outy1 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
