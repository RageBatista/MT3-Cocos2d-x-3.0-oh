//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInstanceSave implements ConvMain.Checkable, Comparable<SInstanceSave> {
    public int id = 0;
    public String name = null;
    public int jinduid = 0;
    public int belongfuben = 0;
    public int maxpoint = 0;
    public ArrayList<String> activeif;
    public ArrayList<String> endif;
    public int activeCG = 0;
    public int endCG = 0;
    public int chestlibid = 0;
    public int chestnum = 0;
    public int awardid = 0;
    public int isstep = 0;
    public String gotoposition = null;
    public int haveboss = 0;
    public int pastaward = 0;
    public int mendaward = 0;
    public int pastexpaward = 0;

    public int compareTo(SInstanceSave o) {
        return this.id - o.id;
    }

    public SInstanceSave() {
    }

    public SInstanceSave(SInstanceSave arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.jinduid = arg.jinduid;
        this.belongfuben = arg.belongfuben;
        this.maxpoint = arg.maxpoint;
        this.activeif = arg.activeif;
        this.endif = arg.endif;
        this.activeCG = arg.activeCG;
        this.endCG = arg.endCG;
        this.chestlibid = arg.chestlibid;
        this.chestnum = arg.chestnum;
        this.awardid = arg.awardid;
        this.isstep = arg.isstep;
        this.gotoposition = arg.gotoposition;
        this.haveboss = arg.haveboss;
        this.pastaward = arg.pastaward;
        this.mendaward = arg.mendaward;
        this.pastexpaward = arg.pastexpaward;
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

    public int getJinduid() {
        return this.jinduid;
    }

    public void setJinduid(int v) {
        this.jinduid = v;
    }

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    public int getMaxpoint() {
        return this.maxpoint;
    }

    public void setMaxpoint(int v) {
        this.maxpoint = v;
    }

    public ArrayList<String> getActiveif() {
        return this.activeif;
    }

    public void setActiveif(ArrayList<String> v) {
        this.activeif = v;
    }

    public ArrayList<String> getEndif() {
        return this.endif;
    }

    public void setEndif(ArrayList<String> v) {
        this.endif = v;
    }

    public int getActiveCG() {
        return this.activeCG;
    }

    public void setActiveCG(int v) {
        this.activeCG = v;
    }

    public int getEndCG() {
        return this.endCG;
    }

    public void setEndCG(int v) {
        this.endCG = v;
    }

    public int getChestlibid() {
        return this.chestlibid;
    }

    public void setChestlibid(int v) {
        this.chestlibid = v;
    }

    public int getChestnum() {
        return this.chestnum;
    }

    public void setChestnum(int v) {
        this.chestnum = v;
    }

    public int getAwardid() {
        return this.awardid;
    }

    public void setAwardid(int v) {
        this.awardid = v;
    }

    public int getIsstep() {
        return this.isstep;
    }

    public void setIsstep(int v) {
        this.isstep = v;
    }

    public String getGotoposition() {
        return this.gotoposition;
    }

    public void setGotoposition(String v) {
        this.gotoposition = v;
    }

    public int getHaveboss() {
        return this.haveboss;
    }

    public void setHaveboss(int v) {
        this.haveboss = v;
    }

    public int getPastaward() {
        return this.pastaward;
    }

    public void setPastaward(int v) {
        this.pastaward = v;
    }

    public int getMendaward() {
        return this.mendaward;
    }

    public void setMendaward(int v) {
        this.mendaward = v;
    }

    public int getPastexpaward() {
        return this.pastexpaward;
    }

    public void setPastexpaward(int v) {
        this.pastexpaward = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
