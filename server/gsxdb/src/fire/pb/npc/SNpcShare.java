//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcShare implements ConvMain.Checkable, Comparable<SNpcShare> {
    public int id = 0;
    public double bodytype = (double)0.0F;
    public int npctype = 0;
    public String minimapshow = null;
    public int share = 0;
    public int shape = 0;
    public String name = null;
    public int mulbattle = 0;
    public int 杂学id = 0;
    public int mapid = 0;
    public int xPos = 0;
    public int yPos = 0;
    public int zPos = 0;
    public int battleinfo = 0;
    public int nametable = 0;
    public int namepre1 = 0;
    public int namepre2 = 0;
    public int diankafu = 0;

    public int compareTo(SNpcShare o) {
        return this.id - o.id;
    }

    public SNpcShare() {
    }

    public SNpcShare(SNpcShare arg) {
        this.id = arg.id;
        this.bodytype = arg.bodytype;
        this.npctype = arg.npctype;
        this.minimapshow = arg.minimapshow;
        this.share = arg.share;
        this.shape = arg.shape;
        this.name = arg.name;
        this.mulbattle = arg.mulbattle;
        this.杂学id = arg.杂学id;
        this.mapid = arg.mapid;
        this.xPos = arg.xPos;
        this.yPos = arg.yPos;
        this.zPos = arg.zPos;
        this.battleinfo = arg.battleinfo;
        this.nametable = arg.nametable;
        this.namepre1 = arg.namepre1;
        this.namepre2 = arg.namepre2;
        this.diankafu = arg.diankafu;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public double getBodytype() {
        return this.bodytype;
    }

    public void setBodytype(double v) {
        this.bodytype = v;
    }

    public int getNpctype() {
        return this.npctype;
    }

    public void setNpctype(int v) {
        this.npctype = v;
    }

    public String getMinimapshow() {
        return this.minimapshow;
    }

    public void setMinimapshow(String v) {
        this.minimapshow = v;
    }

    public int getShare() {
        return this.share;
    }

    public void setShare(int v) {
        this.share = v;
    }

    public int getShape() {
        return this.shape;
    }

    public void setShape(int v) {
        this.shape = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getMulbattle() {
        return this.mulbattle;
    }

    public void setMulbattle(int v) {
        this.mulbattle = v;
    }

    public int get杂学id() {
        return this.杂学id;
    }

    public void set杂学id(int v) {
        this.杂学id = v;
    }

    public int getMapid() {
        return this.mapid;
    }

    public void setMapid(int v) {
        this.mapid = v;
    }

    public int getXPos() {
        return this.xPos;
    }

    public void setXPos(int v) {
        this.xPos = v;
    }

    public int getYPos() {
        return this.yPos;
    }

    public void setYPos(int v) {
        this.yPos = v;
    }

    public int getZPos() {
        return this.zPos;
    }

    public void setZPos(int v) {
        this.zPos = v;
    }

    public int getBattleinfo() {
        return this.battleinfo;
    }

    public void setBattleinfo(int v) {
        this.battleinfo = v;
    }

    public int getNametable() {
        return this.nametable;
    }

    public void setNametable(int v) {
        this.nametable = v;
    }

    public int getNamepre1() {
        return this.namepre1;
    }

    public void setNamepre1(int v) {
        this.namepre1 = v;
    }

    public int getNamepre2() {
        return this.namepre2;
    }

    public void setNamepre2(int v) {
        this.namepre2 = v;
    }

    public int getDiankafu() {
        return this.diankafu;
    }

    public void setDiankafu(int v) {
        this.diankafu = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
