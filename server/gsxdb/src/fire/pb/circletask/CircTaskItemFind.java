//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircTaskItemFind implements ConvMain.Checkable, Comparable<CircTaskItemFind> {
    public int id = 0;
    public int ctgroup = 0;
    public int school = 0;
    public int levelmin = 0;
    public int levelmax = 0;
    public String recycleitem = null;
    public int itemnum = 0;
    public int shopnpc = 0;
    public int islegend = 0;
    public int legendtime = 0;
    public String legenditem = null;
    public int needquality = 0;
    public int qualitya = 0;
    public int qualityb = 0;
    public int teshu = 0;

    public int compareTo(CircTaskItemFind o) {
        return this.id - o.id;
    }

    public CircTaskItemFind() {
    }

    public CircTaskItemFind(CircTaskItemFind arg) {
        this.id = arg.id;
        this.ctgroup = arg.ctgroup;
        this.school = arg.school;
        this.levelmin = arg.levelmin;
        this.levelmax = arg.levelmax;
        this.recycleitem = arg.recycleitem;
        this.itemnum = arg.itemnum;
        this.shopnpc = arg.shopnpc;
        this.islegend = arg.islegend;
        this.legendtime = arg.legendtime;
        this.legenditem = arg.legenditem;
        this.needquality = arg.needquality;
        this.qualitya = arg.qualitya;
        this.qualityb = arg.qualityb;
        this.teshu = arg.teshu;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCtgroup() {
        return this.ctgroup;
    }

    public void setCtgroup(int v) {
        this.ctgroup = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public int getLevelmin() {
        return this.levelmin;
    }

    public void setLevelmin(int v) {
        this.levelmin = v;
    }

    public int getLevelmax() {
        return this.levelmax;
    }

    public void setLevelmax(int v) {
        this.levelmax = v;
    }

    public String getRecycleitem() {
        return this.recycleitem;
    }

    public void setRecycleitem(String v) {
        this.recycleitem = v;
    }

    public int getItemnum() {
        return this.itemnum;
    }

    public void setItemnum(int v) {
        this.itemnum = v;
    }

    public int getShopnpc() {
        return this.shopnpc;
    }

    public void setShopnpc(int v) {
        this.shopnpc = v;
    }

    public int getIslegend() {
        return this.islegend;
    }

    public void setIslegend(int v) {
        this.islegend = v;
    }

    public int getLegendtime() {
        return this.legendtime;
    }

    public void setLegendtime(int v) {
        this.legendtime = v;
    }

    public String getLegenditem() {
        return this.legenditem;
    }

    public void setLegenditem(String v) {
        this.legenditem = v;
    }

    public int getNeedquality() {
        return this.needquality;
    }

    public void setNeedquality(int v) {
        this.needquality = v;
    }

    public int getQualitya() {
        return this.qualitya;
    }

    public void setQualitya(int v) {
        this.qualitya = v;
    }

    public int getQualityb() {
        return this.qualityb;
    }

    public void setQualityb(int v) {
        this.qualityb = v;
    }

    public int getTeshu() {
        return this.teshu;
    }

    public void setTeshu(int v) {
        this.teshu = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
