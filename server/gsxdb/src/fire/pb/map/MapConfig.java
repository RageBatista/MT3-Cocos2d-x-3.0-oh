//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class MapConfig implements ConvMain.Checkable, Comparable<MapConfig> {
    public int id = 0;
    public int enterlv = 0;
    public int minlevel = 0;
    public String mapName = null;
    public String desc = null;
    public int safemap = 0;
    public int dynamic = 0;
    public int relocatemapid = 0;
    public int relocatex = 0;
    public int relocatey = 0;
    public int qinggong = 0;
    public int visibletype = 0;
    public int xjPos = 0;
    public int yjPos = 0;
    public int remap = 0;
    public int rexjPos = 0;
    public int reyjPos = 0;
    public int needvip = 0;
    public int isteam = 0;
    public int isreturn = 0;

    public int compareTo(MapConfig o) {
        return this.id - o.id;
    }

    public MapConfig() {
    }

    public MapConfig(MapConfig arg) {
        this.id = arg.id;
        this.enterlv = arg.enterlv;
        this.minlevel = arg.minlevel;
        this.mapName = arg.mapName;
        this.desc = arg.desc;
        this.safemap = arg.safemap;
        this.dynamic = arg.dynamic;
        this.relocatemapid = arg.relocatemapid;
        this.relocatex = arg.relocatex;
        this.relocatey = arg.relocatey;
        this.qinggong = arg.qinggong;
        this.visibletype = arg.visibletype;
        this.xjPos = arg.xjPos;
        this.yjPos = arg.yjPos;
        this.remap = arg.remap;
        this.rexjPos = arg.rexjPos;
        this.reyjPos = arg.reyjPos;
        this.needvip = arg.needvip;
        this.isteam = arg.isteam;
        this.isreturn = arg.isreturn;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getEnterlv() {
        return this.enterlv;
    }

    public void setEnterlv(int v) {
        this.enterlv = v;
    }

    public int getMinlevel() {
        return this.minlevel;
    }

    public void setMinlevel(int v) {
        this.minlevel = v;
    }

    public String getMapName() {
        return this.mapName;
    }

    public void setMapName(String v) {
        this.mapName = v;
    }

    public String getDesc() {
        return this.desc;
    }

    public void setDesc(String v) {
        this.desc = v;
    }

    public int getSafemap() {
        return this.safemap;
    }

    public void setSafemap(int v) {
        this.safemap = v;
    }

    public int getDynamic() {
        return this.dynamic;
    }

    public void setDynamic(int v) {
        this.dynamic = v;
    }

    public int getRelocatemapid() {
        return this.relocatemapid;
    }

    public void setRelocatemapid(int v) {
        this.relocatemapid = v;
    }

    public int getRelocatex() {
        return this.relocatex;
    }

    public void setRelocatex(int v) {
        this.relocatex = v;
    }

    public int getRelocatey() {
        return this.relocatey;
    }

    public void setRelocatey(int v) {
        this.relocatey = v;
    }

    public int getQinggong() {
        return this.qinggong;
    }

    public void setQinggong(int v) {
        this.qinggong = v;
    }

    public int getVisibletype() {
        return this.visibletype;
    }

    public void setVisibletype(int v) {
        this.visibletype = v;
    }

    public int getXjPos() {
        return this.xjPos;
    }

    public void setXjPos(int v) {
        this.xjPos = v;
    }

    public int getYjPos() {
        return this.yjPos;
    }

    public void setYjPos(int v) {
        this.yjPos = v;
    }

    public int getRemap() {
        return this.remap;
    }

    public void setRemap(int v) {
        this.remap = v;
    }

    public int getRexjPos() {
        return this.rexjPos;
    }

    public void setRexjPos(int v) {
        this.rexjPos = v;
    }

    public int getReyjPos() {
        return this.reyjPos;
    }

    public void setReyjPos(int v) {
        this.reyjPos = v;
    }

    public int getNeedvip() {
        return this.needvip;
    }

    public void setNeedvip(int v) {
        this.needvip = v;
    }

    public int getIsteam() {
        return this.isteam;
    }

    public void setIsteam(int v) {
        this.isteam = v;
    }

    public int getIsreturn() {
        return this.isreturn;
    }

    public void setIsreturn(int v) {
        this.isreturn = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
