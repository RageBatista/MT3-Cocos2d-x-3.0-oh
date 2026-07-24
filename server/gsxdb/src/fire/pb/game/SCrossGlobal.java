//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class SCrossGlobal implements ConvMain.Checkable, Comparable<SCrossGlobal> {
    public int id = 0;
    public int zoneid = 0;
    public int openornot = 0;
    public int session = 0;
    public String list = null;
    public String time = null;
    public int award = 0;
    public String deadline = null;
    public int laba = 0;
    public String ip = null;
    public int duankou = 0;
    public int duankoushu = 0;

    public int compareTo(SCrossGlobal o) {
        return this.id - o.id;
    }

    public SCrossGlobal() {
    }

    public SCrossGlobal(SCrossGlobal arg) {
        this.id = arg.id;
        this.zoneid = arg.zoneid;
        this.openornot = arg.openornot;
        this.session = arg.session;
        this.list = arg.list;
        this.time = arg.time;
        this.award = arg.award;
        this.deadline = arg.deadline;
        this.laba = arg.laba;
        this.ip = arg.ip;
        this.duankou = arg.duankou;
        this.duankoushu = arg.duankoushu;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getZoneid() {
        return this.zoneid;
    }

    public void setZoneid(int v) {
        this.zoneid = v;
    }

    public int getOpenornot() {
        return this.openornot;
    }

    public void setOpenornot(int v) {
        this.openornot = v;
    }

    public int getSession() {
        return this.session;
    }

    public void setSession(int v) {
        this.session = v;
    }

    public String getList() {
        return this.list;
    }

    public void setList(String v) {
        this.list = v;
    }

    public String getTime() {
        return this.time;
    }

    public void setTime(String v) {
        this.time = v;
    }

    public int getAward() {
        return this.award;
    }

    public void setAward(int v) {
        this.award = v;
    }

    public String getDeadline() {
        return this.deadline;
    }

    public void setDeadline(String v) {
        this.deadline = v;
    }

    public int getLaba() {
        return this.laba;
    }

    public void setLaba(int v) {
        this.laba = v;
    }

    public String getIp() {
        return this.ip;
    }

    public void setIp(String v) {
        this.ip = v;
    }

    public int getDuankou() {
        return this.duankou;
    }

    public void setDuankou(int v) {
        this.duankou = v;
    }

    public int getDuankoushu() {
        return this.duankoushu;
    }

    public void setDuankoushu(int v) {
        this.duankoushu = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
