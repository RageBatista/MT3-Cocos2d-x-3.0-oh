//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.Map;
import mytools.ConvMain;

public class SInstaceConfig implements ConvMain.Checkable, Comparable<SInstaceConfig> {
    public int id = 0;
    public String name = null;
    public String classname = null;
    public int serviceid = 0;
    public int afterid = 0;
    public int team = 0;
    public int minlevel = 0;
    public int maxlevel = 0;
    public int playernum = 0;
    public int maxnum = 0;
    public String mapids = null;
    public int mapidfirst = 0;
    public int posxfirst = 0;
    public int posyfirst = 0;
    public int mapidgoto = 0;
    public int posxgoto = 0;
    public int posygoto = 0;
    public int refreshtype = 0;
    public String gototime = null;
    public int gototype = 0;
    public String refreshtime = null;
    public int firstjindu = 0;
    public int lastjindu = 0;
    public int destroy = 0;
    public int iscreate = 0;
    public int xiezhan = 0;

    public int compareTo(SInstaceConfig o) {
        return this.id - o.id;
    }

    public SInstaceConfig() {
    }

    public SInstaceConfig(SInstaceConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.classname = arg.classname;
        this.serviceid = arg.serviceid;
        this.afterid = arg.afterid;
        this.team = arg.team;
        this.minlevel = arg.minlevel;
        this.maxlevel = arg.maxlevel;
        this.playernum = arg.playernum;
        this.maxnum = arg.maxnum;
        this.mapids = arg.mapids;
        this.mapidfirst = arg.mapidfirst;
        this.posxfirst = arg.posxfirst;
        this.posyfirst = arg.posyfirst;
        this.mapidgoto = arg.mapidgoto;
        this.posxgoto = arg.posxgoto;
        this.posygoto = arg.posygoto;
        this.refreshtype = arg.refreshtype;
        this.gototime = arg.gototime;
        this.gototype = arg.gototype;
        this.refreshtime = arg.refreshtime;
        this.firstjindu = arg.firstjindu;
        this.lastjindu = arg.lastjindu;
        this.destroy = arg.destroy;
        this.iscreate = arg.iscreate;
        this.xiezhan = arg.xiezhan;
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

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    public int getServiceid() {
        return this.serviceid;
    }

    public void setServiceid(int v) {
        this.serviceid = v;
    }

    public int getAfterid() {
        return this.afterid;
    }

    public void setAfterid(int v) {
        this.afterid = v;
    }

    public int getTeam() {
        return this.team;
    }

    public void setTeam(int v) {
        this.team = v;
    }

    public int getMinlevel() {
        return this.minlevel;
    }

    public void setMinlevel(int v) {
        this.minlevel = v;
    }

    public int getMaxlevel() {
        return this.maxlevel;
    }

    public void setMaxlevel(int v) {
        this.maxlevel = v;
    }

    public int getPlayernum() {
        return this.playernum;
    }

    public void setPlayernum(int v) {
        this.playernum = v;
    }

    public int getMaxnum() {
        return this.maxnum;
    }

    public void setMaxnum(int v) {
        this.maxnum = v;
    }

    public String getMapids() {
        return this.mapids;
    }

    public void setMapids(String v) {
        this.mapids = v;
    }

    public int getMapidfirst() {
        return this.mapidfirst;
    }

    public void setMapidfirst(int v) {
        this.mapidfirst = v;
    }

    public int getPosxfirst() {
        return this.posxfirst;
    }

    public void setPosxfirst(int v) {
        this.posxfirst = v;
    }

    public int getPosyfirst() {
        return this.posyfirst;
    }

    public void setPosyfirst(int v) {
        this.posyfirst = v;
    }

    public int getMapidgoto() {
        return this.mapidgoto;
    }

    public void setMapidgoto(int v) {
        this.mapidgoto = v;
    }

    public int getPosxgoto() {
        return this.posxgoto;
    }

    public void setPosxgoto(int v) {
        this.posxgoto = v;
    }

    public int getPosygoto() {
        return this.posygoto;
    }

    public void setPosygoto(int v) {
        this.posygoto = v;
    }

    public int getRefreshtype() {
        return this.refreshtype;
    }

    public void setRefreshtype(int v) {
        this.refreshtype = v;
    }

    public String getGototime() {
        return this.gototime;
    }

    public void setGototime(String v) {
        this.gototime = v;
    }

    public int getGototype() {
        return this.gototype;
    }

    public void setGototype(int v) {
        this.gototype = v;
    }

    public String getRefreshtime() {
        return this.refreshtime;
    }

    public void setRefreshtime(String v) {
        this.refreshtime = v;
    }

    public int getFirstjindu() {
        return this.firstjindu;
    }

    public void setFirstjindu(int v) {
        this.firstjindu = v;
    }

    public int getLastjindu() {
        return this.lastjindu;
    }

    public void setLastjindu(int v) {
        this.lastjindu = v;
    }

    public int getDestroy() {
        return this.destroy;
    }

    public void setDestroy(int v) {
        this.destroy = v;
    }

    public int getIscreate() {
        return this.iscreate;
    }

    public void setIscreate(int v) {
        this.iscreate = v;
    }

    public int getXiezhan() {
        return this.xiezhan;
    }

    public void setXiezhan(int v) {
        this.xiezhan = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
