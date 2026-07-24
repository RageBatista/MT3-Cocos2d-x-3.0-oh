//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi.spotcheck;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleTradingRecord implements Marshal {
    public String tradingid;
    public int tradingtype;
    public int num;
    public int price;
    public long tradingtime;

    public RoleTradingRecord() {
        this.tradingid = "";
    }

    public RoleTradingRecord(String _tradingid_, int _tradingtype_, int _num_, int _price_, long _tradingtime_) {
        this.tradingid = _tradingid_;
        this.tradingtype = _tradingtype_;
        this.num = _num_;
        this.price = _price_;
        this.tradingtime = _tradingtime_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.tradingid, "UTF-16LE");
        _os_.marshal(this.tradingtype);
        _os_.marshal(this.num);
        _os_.marshal(this.price);
        _os_.marshal(this.tradingtime);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.tradingid = _os_.unmarshal_String("UTF-16LE");
        this.tradingtype = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.price = _os_.unmarshal_int();
        this.tradingtime = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleTradingRecord) {
            RoleTradingRecord _o_ = (RoleTradingRecord)_o1_;
            if (!this.tradingid.equals(_o_.tradingid)) {
                return false;
            } else if (this.tradingtype != _o_.tradingtype) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else {
                return this.tradingtime == _o_.tradingtime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.tradingid.hashCode();
        _h_ += this.tradingtype;
        _h_ += this.num;
        _h_ += this.price;
        _h_ += (int)this.tradingtime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.tradingid.length()).append(",");
        _sb_.append(this.tradingtype).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.tradingtime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
