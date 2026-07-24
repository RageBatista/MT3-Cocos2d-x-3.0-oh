//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircTaskConf implements ConvMain.Checkable, Comparable<CircTaskConf> {
    public int id = 0;
    public String strtaskname = null;
    public int cttype = 0;
    public int ctgroup = 0;
    public int gototype = 0;
    public int autocomp = 0;
    public String submitnpc = null;
    public int awardid = 0;
    public int matchtype = 0;
    public String awardids = null;
    public int isrenxing = 0;
    public int nextquest = 0;
    public int completetip = 0;
    public int tasklevel = 0;

    public int compareTo(CircTaskConf o) {
        return this.id - o.id;
    }

    public CircTaskConf() {
    }

    public CircTaskConf(CircTaskConf arg) {
        this.id = arg.id;
        this.strtaskname = arg.strtaskname;
        this.cttype = arg.cttype;
        this.ctgroup = arg.ctgroup;
        this.gototype = arg.gototype;
        this.autocomp = arg.autocomp;
        this.submitnpc = arg.submitnpc;
        this.awardid = arg.awardid;
        this.matchtype = arg.matchtype;
        this.awardids = arg.awardids;
        this.isrenxing = arg.isrenxing;
        this.nextquest = arg.nextquest;
        this.completetip = arg.completetip;
        this.tasklevel = arg.tasklevel;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getStrtaskname() {
        return this.strtaskname;
    }

    public void setStrtaskname(String v) {
        this.strtaskname = v;
    }

    public int getCttype() {
        return this.cttype;
    }

    public void setCttype(int v) {
        this.cttype = v;
    }

    public int getCtgroup() {
        return this.ctgroup;
    }

    public void setCtgroup(int v) {
        this.ctgroup = v;
    }

    public int getGototype() {
        return this.gototype;
    }

    public void setGototype(int v) {
        this.gototype = v;
    }

    public int getAutocomp() {
        return this.autocomp;
    }

    public void setAutocomp(int v) {
        this.autocomp = v;
    }

    public String getSubmitnpc() {
        return this.submitnpc;
    }

    public void setSubmitnpc(String v) {
        this.submitnpc = v;
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

    public int getIsrenxing() {
        return this.isrenxing;
    }

    public void setIsrenxing(int v) {
        this.isrenxing = v;
    }

    public int getNextquest() {
        return this.nextquest;
    }

    public void setNextquest(int v) {
        this.nextquest = v;
    }

    public int getCompletetip() {
        return this.completetip;
    }

    public void setCompletetip(int v) {
        this.completetip = v;
    }

    public int getTasklevel() {
        return this.tasklevel;
    }

    public void setTasklevel(int v) {
        this.tasklevel = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
