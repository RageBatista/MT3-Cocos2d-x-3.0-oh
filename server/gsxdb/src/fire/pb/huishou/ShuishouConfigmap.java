package fire.pb.huishou;

import java.util.Map;
import mytools.ConvMain;

public class ShuishouConfigmap implements ConvMain.Checkable, Comparable<ShuishouConfigmap> {
    public int id = 0;              // 配置ID
    public int type = 0;            // 物品类型: 1=装备制造书, 2=道具, 3=限时
    public int itmeid = 0;          // 物品ID
    public String itemname = null;  // 物品名称
    public int moneytype = 0;       // 货币类型: 1=铜币, 2=元宝, 3=符石
    public int moneynum = 0;        // 单价
    public int max = 0;             // 每日最大回购数量
    public int enable = 0;          // 启用状态: 0=禁用, 1=启用
    public String startTime = null; // 活动开始时间, "0"表示无限制
    public String endTime = null;   // 活动结束时间, "0"表示无限制

    public ShuishouConfigmap() {
    }

    public ShuishouConfigmap(ShuishouConfigmap arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.itmeid = arg.itmeid;
        this.itemname = arg.itemname;
        this.moneytype = arg.moneytype;
        this.moneynum = arg.moneynum;
        this.max = arg.max;
        this.enable = arg.enable;
        this.startTime = arg.startTime;
        this.endTime = arg.endTime;
    }

    @Override
    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        // 目前不做额外校验，保留扩展点
    }

    @Override
    public int compareTo(ShuishouConfigmap o) {
        return this.id - o.id;
    }

    public int getId() {
        return this.id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getItmeid() {
        return this.itmeid;
    }

    public void setItmeid(int itmeid) {
        this.itmeid = itmeid;
    }

    public String getItemname() {
        return this.itemname;
    }

    public void setItemname(String itemname) {
        this.itemname = itemname;
    }

    public int getMoneytype() {
        return this.moneytype;
    }

    public void setMoneytype(int moneytype) {
        this.moneytype = moneytype;
    }

    public int getMoneynum() {
        return this.moneynum;
    }

    public void setMoneynum(int moneynum) {
        this.moneynum = moneynum;
    }

    public int getMax() {
        return this.max;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public int getEnable() {
        return this.enable;
    }

    public void setEnable(int enable) {
        this.enable = enable;
    }

    public String getStartTime() {
        return this.startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return this.endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
