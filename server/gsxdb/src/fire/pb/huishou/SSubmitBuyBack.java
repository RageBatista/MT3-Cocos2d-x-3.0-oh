package fire.pb.huishou;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

/** 提交回购响应协议 S2C (819410) */
public class SSubmitBuyBack extends __SSubmitBuyBack__ {

    public static final int PROTOCOL_TYPE = 819410;

    public int itemid;  // 物品ID
    public int itemnum; // 背包剩余数量
    public int backnum; // 当日剩余可回购额度

    /** 默认构造函数 */
    public SSubmitBuyBack() {
    }

    /** 全参数构造函数 */
    public SSubmitBuyBack(int itemid, int itemnum, int backnum) {
        this.itemid = itemid;
        this.itemnum = itemnum;
        this.backnum = backnum;
    }

    @Override
    public int getType() {
        return PROTOCOL_TYPE;
    }

    @Override
    protected void process() {
        // S2C协议, 无需处理
    }

    public final boolean _validator_() {
        return true;
    }

    @Override
    public OctetsStream marshal(OctetsStream os) {
        os.marshal(this.itemid);
        os.marshal(this.itemnum);
        os.marshal(this.backnum);
        return os;
    }

    @Override
    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        this.itemid = os.unmarshal_int();
        this.itemnum = os.unmarshal_int();
        this.backnum = os.unmarshal_int();
        return os;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash = hash * 31 + itemid;
        hash = hash * 31 + itemnum;
        hash = hash * 31 + backnum;
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof SSubmitBuyBack)) {
            return false;
        }
        SSubmitBuyBack other = (SSubmitBuyBack) obj;
        return this.itemid == other.itemid
                && this.itemnum == other.itemnum
                && this.backnum == other.backnum;
    }

    @Override
    public String toString() {
        return "SSubmitBuyBack(" +
                "itemid=" + itemid + "," +
                "itemnum=" + itemnum + "," +
                "backnum=" + backnum +
                ")";
    }
}
