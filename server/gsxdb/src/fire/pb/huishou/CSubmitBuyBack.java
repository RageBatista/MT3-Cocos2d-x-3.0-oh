package fire.pb.huishou;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

/** 提交回购请求协议 C2S (819409) */
public class CSubmitBuyBack extends __CSubmitBuyBack__
        implements Comparable<CSubmitBuyBack> {

    public static final int PROTOCOL_TYPE = 819409;

    public int itemid;      // 物品ID
    public int itemtype;    // 物品类型: 1=装备, 2=道具
    public int istimelimit; // 是否限时: 0=否, 1=是
    public int num;         // 回购数量(1-99)

    /** 默认构造函数 */
    public CSubmitBuyBack() {
    }

    /** 全参数构造函数 */
    public CSubmitBuyBack(int itemid, int itemtype, int istimelimit, int num) {
        this.itemid = itemid;
        this.itemtype = itemtype;
        this.istimelimit = istimelimit;
        if (!isValidNum(num)) {
            throw new IllegalArgumentException(
                    "回购数量必须在 [1, 99] 范围内，实际值：" + num);
        }
        this.num = num;
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

        new PSubmitBuyBack(
                roleId,
                this.itemid,
                this.itemtype,
                this.istimelimit,
                this.num
        ).submit();
    }

    public final boolean _validator_() {
        return isValidNum(this.num);
    }

    private boolean isValidNum(int n) {
        return n >= 1 && n <= 99;
    }

    @Override
    public OctetsStream marshal(OctetsStream os) {
        if (!_validator_()) {
            throw new VerifyError("validator failed");
        }
        os.marshal(this.itemid);
        os.marshal(this.itemtype);
        os.marshal(this.istimelimit);
        os.marshal(this.num);
        return os;
    }

    @Override
    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        this.itemid = os.unmarshal_int();
        this.itemtype = os.unmarshal_int();
        this.istimelimit = os.unmarshal_int();
        this.num = os.unmarshal_int();
        if (!_validator_()) {
            throw new VerifyError("validator failed");
        }
        return os;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash = hash * 31 + itemid;
        hash = hash * 31 + itemtype;
        hash = hash * 31 + istimelimit;
        hash = hash * 31 + num;
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof CSubmitBuyBack)) {
            return false;
        }
        CSubmitBuyBack other = (CSubmitBuyBack) obj;
        return this.itemid == other.itemid
                && this.itemtype == other.itemtype
                && this.istimelimit == other.istimelimit
                && this.num == other.num;
    }

    @Override
    public int compareTo(CSubmitBuyBack o) {
        if (o == this) return 0;
        int c = this.itemid - o.itemid;
        if (c != 0) return c;
        c = this.itemtype - o.itemtype;
        if (c != 0) return c;
        c = this.istimelimit - o.istimelimit;
        if (c != 0) return c;
        return this.num - o.num;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("CSubmitBuyBack(");
        sb.append("itemid=").append(itemid).append(',');
        sb.append("itemtype=").append(itemtype).append(',');
        sb.append("istimelimit=").append(istimelimit).append(',');
        sb.append("num=").append(num);
        sb.append(')');
        return sb.toString();
    }
}
