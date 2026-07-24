package fire.pb.huishou;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

import java.util.LinkedList;

/** 回购列表响应协议 S2C (819408) */
public class SItemBuyBackList extends __SItemBuyBackList__ {

    public static final int PROTOCOL_TYPE = 819408;

    public int findtype;    // 查询类型: 1=普通, 3=限时, 4=历史记录
    public int itemtype;    // 物品类型: 1=装备, 2=道具
    public int istimelimit; // 是否限时: 0=否, 1=是
    public int page;        // 当前页码(从1开始)
    public int pagesize;    // 每页大小
    public int pagetotal;   // 总页数
    public LinkedList<ItemBuyBackOs> itembuybackos; // 回购物品列表

    /** 默认构造函数 */
    public SItemBuyBackList() {
        this.itembuybackos = new LinkedList<>();
    }

    /** 全参数构造函数 */
    public SItemBuyBackList(int findtype, int itemtype, int istimelimit,
                            int page, int pagesize, int pagetotal,
                            LinkedList<ItemBuyBackOs> itembuybackos) {
        this.findtype = findtype;
        this.itemtype = itemtype;
        this.istimelimit = istimelimit;
        this.page = page;
        this.pagesize = pagesize;
        this.pagetotal = pagetotal;
        this.itembuybackos = itembuybackos != null ? itembuybackos
                : new LinkedList<ItemBuyBackOs>();
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
        if (itembuybackos == null) {
            return false;
        }
        for (ItemBuyBackOs item : itembuybackos) {
            if (item == null || !item._validator_()) {
                return false;
            }
        }
        return true;
    }

    @Override
    public OctetsStream marshal(OctetsStream os) {
        if (!_validator_()) {
            throw new VerifyError("validator failed");
        }
        os.marshal(this.findtype);
        os.marshal(this.itemtype);
        os.marshal(this.istimelimit);
        os.marshal(this.page);
        os.marshal(this.pagesize);
        os.marshal(this.pagetotal);
        os.compact_uint32(this.itembuybackos.size());
        for (ItemBuyBackOs item : this.itembuybackos) {
            os.marshal(item);
        }
        return os;
    }

    @Override
    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        this.findtype = os.unmarshal_int();
        this.itemtype = os.unmarshal_int();
        this.istimelimit = os.unmarshal_int();
        this.page = os.unmarshal_int();
        this.pagesize = os.unmarshal_int();
        this.pagetotal = os.unmarshal_int();
        int count = os.uncompact_uint32();
        this.itembuybackos = new LinkedList<>();
        while (count-- > 0) {
            ItemBuyBackOs item = new ItemBuyBackOs();
            item.unmarshal(os);
            this.itembuybackos.add(item);
        }
        if (!_validator_()) {
            throw new VerifyError("validator failed");
        }
        return os;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash = hash * 31 + findtype;
        hash = hash * 31 + itemtype;
        hash = hash * 31 + istimelimit;
        hash = hash * 31 + page;
        hash = hash * 31 + pagesize;
        hash = hash * 31 + pagetotal;
        hash = hash * 31 + (itembuybackos != null ? itembuybackos.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof SItemBuyBackList)) {
            return false;
        }
        SItemBuyBackList other = (SItemBuyBackList) obj;
        return this.findtype == other.findtype
                && this.itemtype == other.itemtype
                && this.istimelimit == other.istimelimit
                && this.page == other.page
                && this.pagesize == other.pagesize
                && this.pagetotal == other.pagetotal
                && (this.itembuybackos == null ? other.itembuybackos == null
                        : this.itembuybackos.equals(other.itembuybackos));
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("SItemBuyBackList(");
        sb.append("findtype=").append(findtype).append(',');
        sb.append("itemtype=").append(itemtype).append(',');
        sb.append("istimelimit=").append(istimelimit).append(',');
        sb.append("page=").append(page).append(',');
        sb.append("pagesize=").append(pagesize).append(',');
        sb.append("pagetotal=").append(pagetotal).append(',');
        sb.append("items=").append(itembuybackos != null ? itembuybackos.size() : 0);
        sb.append(')');
        return sb.toString();
    }
}
