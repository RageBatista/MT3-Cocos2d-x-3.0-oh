//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInstaceNpc implements ConvMain.Checkable, Comparable<SInstaceNpc> {
    public int id = 0;
    public String name = null;
    public int belongfuben = 0;
    public int friststate = 0;
    public String srrviceslist = null;
    public int actId = 0;
    public String jinduidlist = null;
    public int rolenumber = 0;
    public int npcminnumber = 0;
    public int npcmaxnumber = 0;
    public int baoxiangid = 0;
    public int baoxingnumber = 0;
    public int npctype = 0;
    public ArrayList<String> changestate;
    public int awardid = 0;
    public int matchtype = 0;
    public String awardids = null;
    public int posx = 0;
    public int posy = 0;
    public int multibattle = 0;

    public int compareTo(SInstaceNpc o) {
        return this.id - o.id;
    }

    public SInstaceNpc() {
    }

    public SInstaceNpc(SInstaceNpc arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.belongfuben = arg.belongfuben;
        this.friststate = arg.friststate;
        this.srrviceslist = arg.srrviceslist;
        this.actId = arg.actId;
        this.jinduidlist = arg.jinduidlist;
        this.rolenumber = arg.rolenumber;
        this.npcminnumber = arg.npcminnumber;
        this.npcmaxnumber = arg.npcmaxnumber;
        this.baoxiangid = arg.baoxiangid;
        this.baoxingnumber = arg.baoxingnumber;
        this.npctype = arg.npctype;
        this.changestate = arg.changestate;
        this.awardid = arg.awardid;
        this.matchtype = arg.matchtype;
        this.awardids = arg.awardids;
        this.posx = arg.posx;
        this.posy = arg.posy;
        this.multibattle = arg.multibattle;
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

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    public int getFriststate() {
        return this.friststate;
    }

    public void setFriststate(int v) {
        this.friststate = v;
    }

    public String getSrrviceslist() {
        return this.srrviceslist;
    }

    public void setSrrviceslist(String v) {
        this.srrviceslist = v;
    }

    public int getActId() {
        return this.actId;
    }

    public void setActId(int v) {
        this.actId = v;
    }

    public String getJinduidlist() {
        return this.jinduidlist;
    }

    public void setJinduidlist(String v) {
        this.jinduidlist = v;
    }

    public int getRolenumber() {
        return this.rolenumber;
    }

    public void setRolenumber(int v) {
        this.rolenumber = v;
    }

    public int getNpcminnumber() {
        return this.npcminnumber;
    }

    public void setNpcminnumber(int v) {
        this.npcminnumber = v;
    }

    public int getNpcmaxnumber() {
        return this.npcmaxnumber;
    }

    public void setNpcmaxnumber(int v) {
        this.npcmaxnumber = v;
    }

    public int getBaoxiangid() {
        return this.baoxiangid;
    }

    public void setBaoxiangid(int v) {
        this.baoxiangid = v;
    }

    public int getBaoxingnumber() {
        return this.baoxingnumber;
    }

    public void setBaoxingnumber(int v) {
        this.baoxingnumber = v;
    }

    public int getNpctype() {
        return this.npctype;
    }

    public void setNpctype(int v) {
        this.npctype = v;
    }

    public ArrayList<String> getChangestate() {
        return this.changestate;
    }

    public void setChangestate(ArrayList<String> v) {
        this.changestate = v;
    }

    public int getAwardid() {
        return this.awardid;
    }

    public void setAwardid(int v) {
        this.awardid = v;
    }

    public int getMatchtype() {
        return this.matchtype;
    }

    public void setMatchtype(int v) {
        this.matchtype = v;
    }

    public String getAwardids() {
        return this.awardids;
    }

    public void setAwardids(String v) {
        this.awardids = v;
    }

    public int getPosx() {
        return this.posx;
    }

    public void setPosx(int v) {
        this.posx = v;
    }

    public int getPosy() {
        return this.posy;
    }

    public void setPosy(int v) {
        this.posy = v;
    }

    public int getMultibattle() {
        return this.multibattle;
    }

    public void setMultibattle(int v) {
        this.multibattle = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
