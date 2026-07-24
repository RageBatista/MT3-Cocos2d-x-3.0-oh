package fire.pb.huishou;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

/**
 * 回购物品数据传输对象 (DTO)
 * 注意: 部分字段在不同场景下有不同语义
 * - 配置列表模式 (findType=1/3): getstatus=货币类型, recoverynum=剩余额度
 * - 历史记录模式 (findType=4): getstatus=累计数量, recoverynum=本次数量
 */
public class ItemBuyBackOs implements Marshal {

    public int id;              // 配置ID 或 序号(历史记录)
    public int itemtype;        // 物品类型: 1=装备, 2=道具, 3=限时
    public int timelimit;       // 启用状态(配置) 或 占位(历史)
    public int timelimitnum;    // 占位字段
    public int itemid;          // 物品ID
    public String itemname;     // 物品名称(历史记录为空)
    public int recoveryprice;   // 回购单价
    public int recoverynum;     // 可回购数量(配置) 或 本次数量(历史)
    public int getstatus;       // 货币类型(配置) 或 累计数量(历史)
    public String starttime;    // 活动开始时间(配置) 或 回购时间戳(历史)
    public String endtime;      // 活动结束时间(配置) 或 占位(历史)

    /**
     * 默认构造函数
     */
    public ItemBuyBackOs() {
        this.itemname = "";
        this.starttime = "";
        this.endtime = "";
    }

    /**
     * 全参数构造函数
     */
    public ItemBuyBackOs(int id, int itemtype, int timelimit, int timelimitnum, int itemid, String itemname, int recoveryprice, int recoverynum, int getstatus, String starttime, String endtime) {
        this.id = id;
        this.itemtype = itemtype;
        this.timelimit = timelimit;
        this.timelimitnum = timelimitnum;
        this.itemid = itemid;
        this.itemname = itemname;
        this.recoveryprice = recoveryprice;
        this.recoverynum = recoverynum;
        this.getstatus = getstatus;
        this.starttime = starttime;
        this.endtime = endtime;
    }

    @Override
    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.itemtype);
        _os_.marshal(this.timelimit);
        _os_.marshal(this.timelimitnum);
        _os_.marshal(this.itemid);
        _os_.marshal(this.itemname, "UTF-16LE");
        _os_.marshal(this.recoveryprice);
        _os_.marshal(this.recoverynum);
        _os_.marshal(this.getstatus);
        _os_.marshal(this.starttime, "UTF-16LE");
        _os_.marshal(this.endtime, "UTF-16LE");
        return _os_;
    }

    @Override
    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.itemtype = _os_.unmarshal_int();
        this.timelimit = _os_.unmarshal_int();
        this.timelimitnum = _os_.unmarshal_int();
        this.itemid = _os_.unmarshal_int();
        this.itemname = _os_.unmarshal_String("UTF-16LE");
        this.recoveryprice = _os_.unmarshal_int();
        this.recoverynum = _os_.unmarshal_int();
        this.getstatus = _os_.unmarshal_int();
        this.starttime = _os_.unmarshal_String("UTF-16LE");
        this.endtime = _os_.unmarshal_String("UTF-16LE");
        return _os_;
    }

    @Override
    public boolean equals(Object _o1_) {
        if (_o1_ == this) return true;
        if (_o1_ instanceof ItemBuyBackOs) {
            ItemBuyBackOs _o_ = (ItemBuyBackOs) _o1_;
            return this.id == _o_.id
                    && this.itemtype == _o_.itemtype
                    && this.timelimit == _o_.timelimit
                    && this.timelimitnum == _o_.timelimitnum
                    && this.itemid == _o_.itemid
                    && this.itemname.equals(_o_.itemname)
                    && this.recoveryprice == _o_.recoveryprice
                    && this.recoverynum == _o_.recoverynum
                    && this.getstatus == _o_.getstatus
                    && this.starttime.equals(_o_.starttime)
                    && this.endtime.equals(_o_.endtime);
        }
        return false;
    }

    public final boolean _validator_() {
        return true;
    }

    @Override
    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.itemtype;
        _h_ += this.timelimit;
        _h_ += this.timelimitnum;
        _h_ += this.itemid;
        _h_ += this.itemname.hashCode();
        _h_ += this.recoveryprice;
        _h_ += this.recoverynum;
        _h_ += this.getstatus;
        _h_ += this.starttime.hashCode();
        _h_ += this.endtime.hashCode();
        return _h_;
    }

    @Override
    public String toString() {
        return "(" +
                this.id + "," +
                this.itemtype + "," +
                this.timelimit + "," +
                this.timelimitnum + "," +
                this.itemid + "," +
                this.itemname + "," +
                this.recoveryprice + "," +
                this.recoverynum + "," +
                this.getstatus + "," +
                this.starttime + "," +
                this.endtime +
                ")";
    }
}
