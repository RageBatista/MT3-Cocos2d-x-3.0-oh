//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class SWorldMapConfig implements ConvMain.Checkable, Comparable<SWorldMapConfig> {
    public int id = 0;
    public int maptype = 0;
    public int LevelLimitMin = 0;
    public int LevelLimitMax = 0;
    public String SubUnderGroundMap = null;
    public int topx = 0;
    public int topy = 0;
    public int bottomx = 0;
    public int bottomy = 0;

    public int compareTo(SWorldMapConfig o) {
        return this.id - o.id;
    }

    public SWorldMapConfig() {
    }

    public SWorldMapConfig(SWorldMapConfig arg) {
        this.id = arg.id;
        this.maptype = arg.maptype;
        this.LevelLimitMin = arg.LevelLimitMin;
        this.LevelLimitMax = arg.LevelLimitMax;
        this.SubUnderGroundMap = arg.SubUnderGroundMap;
        this.topx = arg.topx;
        this.topy = arg.topy;
        this.bottomx = arg.bottomx;
        this.bottomy = arg.bottomy;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMaptype() {
        return this.maptype;
    }

    public void setMaptype(int v) {
        this.maptype = v;
    }

    public int getLevelLimitMin() {
        return this.LevelLimitMin;
    }

    public void setLevelLimitMin(int v) {
        this.LevelLimitMin = v;
    }

    public int getLevelLimitMax() {
        return this.LevelLimitMax;
    }

    public void setLevelLimitMax(int v) {
        this.LevelLimitMax = v;
    }

    public String getSubUnderGroundMap() {
        return this.SubUnderGroundMap;
    }

    public void setSubUnderGroundMap(String v) {
        this.SubUnderGroundMap = v;
    }

    public int getTopx() {
        return this.topx;
    }

    public void setTopx(int v) {
        this.topx = v;
    }

    public int getTopy() {
        return this.topy;
    }

    public void setTopy(int v) {
        this.topy = v;
    }

    public int getBottomx() {
        return this.bottomx;
    }

    public void setBottomx(int v) {
        this.bottomx = v;
    }

    public int getBottomy() {
        return this.bottomy;
    }

    public void setBottomy(int v) {
        this.bottomy = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
