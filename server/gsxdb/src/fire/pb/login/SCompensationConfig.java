//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.login;

import java.util.Map;
import mytools.ConvMain;

public class SCompensationConfig implements ConvMain.Checkable, Comparable<SCompensationConfig> {
    public int id = 0;
    public int compensationid = 0;
    public String startTime = null;
    public String endTime = null;
    public String serviceName = null;
    public int msgid = 0;
    public int itemid = 0;
    public String roleid = null;
    public String userid = null;
    public String serverid = null;
    public String onChannel = null;
    public String offChannel = null;
    public String conditionid = null;

    public int compareTo(SCompensationConfig o) {
        return this.id - o.id;
    }

    public SCompensationConfig() {
    }

    public SCompensationConfig(SCompensationConfig arg) {
        this.id = arg.id;
        this.compensationid = arg.compensationid;
        this.startTime = arg.startTime;
        this.endTime = arg.endTime;
        this.serviceName = arg.serviceName;
        this.msgid = arg.msgid;
        this.itemid = arg.itemid;
        this.roleid = arg.roleid;
        this.userid = arg.userid;
        this.serverid = arg.serverid;
        this.onChannel = arg.onChannel;
        this.offChannel = arg.offChannel;
        this.conditionid = arg.conditionid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCompensationid() {
        return this.compensationid;
    }

    public void setCompensationid(int v) {
        this.compensationid = v;
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

    public String getServiceName() {
        return this.serviceName;
    }

    public void setServiceName(String v) {
        this.serviceName = v;
    }

    public int getMsgid() {
        return this.msgid;
    }

    public void setMsgid(int v) {
        this.msgid = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    public String getRoleid() {
        return this.roleid;
    }

    public void setRoleid(String v) {
        this.roleid = v;
    }

    public String getUserid() {
        return this.userid;
    }

    public void setUserid(String v) {
        this.userid = v;
    }

    public String getServerid() {
        return this.serverid;
    }

    public void setServerid(String v) {
        this.serverid = v;
    }

    public String getOnChannel() {
        return this.onChannel;
    }

    public void setOnChannel(String v) {
        this.onChannel = v;
    }

    public String getOffChannel() {
        return this.offChannel;
    }

    public void setOffChannel(String v) {
        this.offChannel = v;
    }

    public String getConditionid() {
        return this.conditionid;
    }

    public void setConditionid(String v) {
        this.conditionid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
