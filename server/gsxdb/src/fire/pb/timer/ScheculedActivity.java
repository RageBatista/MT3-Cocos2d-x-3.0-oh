//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.timer;

import java.util.Map;
import mytools.ConvMain;

public class ScheculedActivity implements ConvMain.Checkable {
    public int id = 0;
    public int activityid = 0;
    public String zoneid = null;
    public String startTime = null;
    public String endTime = null;
    public int remind = 0;
    public int latetime = 0;
    public int advanceremind = 0;
    public int weekrepeat = 0;

    public ScheculedActivity() {
    }

    public ScheculedActivity(ScheculedActivity arg) {
        this.id = arg.id;
        this.activityid = arg.activityid;
        this.zoneid = arg.zoneid;
        this.startTime = arg.startTime;
        this.endTime = arg.endTime;
        this.remind = arg.remind;
        this.latetime = arg.latetime;
        this.advanceremind = arg.advanceremind;
        this.weekrepeat = arg.weekrepeat;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getActivityid() {
        return this.activityid;
    }

    public void setActivityid(int v) {
        this.activityid = v;
    }

    public String getZoneid() {
        return this.zoneid;
    }

    public void setZoneid(String v) {
        this.zoneid = v;
    }

    public String getStartTime() {
        return this.startTime;
    }

    public void setStartTime(String v) {
        this.startTime = v;
    }

    public String getEndTime() {
        return this.endTime;
    }

    public void setEndTime(String v) {
        this.endTime = v;
    }

    public int getRemind() {
        return this.remind;
    }

    public void setRemind(int v) {
        this.remind = v;
    }

    public int getLatetime() {
        return this.latetime;
    }

    public void setLatetime(int v) {
        this.latetime = v;
    }

    public int getAdvanceremind() {
        return this.advanceremind;
    }

    public void setAdvanceremind(int v) {
        this.advanceremind = v;
    }

    public int getWeekrepeat() {
        return this.weekrepeat;
    }

    public void setWeekrepeat(int v) {
        this.weekrepeat = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
