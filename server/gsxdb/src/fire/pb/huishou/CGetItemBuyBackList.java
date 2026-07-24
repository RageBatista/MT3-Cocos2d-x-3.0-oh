package fire.pb.huishou;

import gnet.link.Onlines;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

/** 获取回购列表 C2S协议 (819407) */
public class CGetItemBuyBackList extends __CGetItemBuyBackList__
        implements Comparable<CGetItemBuyBackList> {

    public static final int PROTOCOL_TYPE = 819407;

    public int findtype;    // 查询类型: 1=普通, 3=限时, 4=历史记录
    public int itemtype;    // 物品类型: 1=装备, 2=道具
    public int istimelimit; // 是否限时: 0=否, 1=是
    public int page;        // 页码(从1开始)
    public int pagesize;    // 每页大小(固定10)

    public CGetItemBuyBackList() {
    }

    public CGetItemBuyBackList(int findtype, int itemtype,
                               int istimelimit, int page, int pagesize) {
        this.findtype = findtype;
        this.itemtype = itemtype;
        this.istimelimit = istimelimit;
        this.page = page;
        this.pagesize = pagesize;
    }

    @Override
    public int getType() {
        return PROTOCOL_TYPE;
    }

    @Override
    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId <= 0L) {
            return;
        }

        new PGetItemBuyBackList(
                roleId,
                this.findtype,
                this.itemtype,
                this.istimelimit,
                this.page,
                this.pagesize
        ).submit();
    }

    public final boolean _validator_() {
        return page > 0 && pagesize > 0;
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
        return os;
    }

    @Override
    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        this.findtype = os.unmarshal_int();
        this.itemtype = os.unmarshal_int();
        this.istimelimit = os.unmarshal_int();
        this.page = os.unmarshal_int();
        this.pagesize = os.unmarshal_int();
        if (!_validator_()) {
            throw new VerifyError("validator failed");
        }
        return os;
    }

    @Override
    public int compareTo(CGetItemBuyBackList o) {
        if (o == this) return 0;
        int c = this.findtype - o.findtype;
        if (c != 0) return c;
        c = this.itemtype - o.itemtype;
        if (c != 0) return c;
        c = this.istimelimit - o.istimelimit;
        if (c != 0) return c;
        c = this.page - o.page;
        if (c != 0) return c;
        return this.pagesize - o.pagesize;
    }

    @Override
    public int hashCode() {
        int h = 0;
        h = h * 31 + findtype;
        h = h * 31 + itemtype;
        h = h * 31 + istimelimit;
        h = h * 31 + page;
        h = h * 31 + pagesize;
        return h;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (!(obj instanceof CGetItemBuyBackList)) return false;
        CGetItemBuyBackList o = (CGetItemBuyBackList) obj;
        return this.findtype == o.findtype
                && this.itemtype == o.itemtype
                && this.istimelimit == o.istimelimit
                && this.page == o.page
                && this.pagesize == o.pagesize;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append('(');
        sb.append("findtype=").append(findtype).append(',');
        sb.append("itemtype=").append(itemtype).append(',');
        sb.append("istimelimit=").append(istimelimit).append(',');
        sb.append("page=").append(page).append(',');
        sb.append("pagesize=").append(pagesize);
        sb.append(')');
        return sb.toString();
    }
}
