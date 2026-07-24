//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RollMelon implements Marshal {
    public long melonid;
    public int itemid;
    public int itemnum;
    public Octets itemdata;

    public RollMelon() {
        this.itemdata = new Octets();
    }

    public RollMelon(long _melonid_, int _itemid_, int _itemnum_, Octets _itemdata_) {
        this.melonid = _melonid_;
        this.itemid = _itemid_;
        this.itemnum = _itemnum_;
        this.itemdata = _itemdata_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.melonid);
        _os_.marshal(this.itemid);
        _os_.marshal(this.itemnum);
        _os_.marshal(this.itemdata);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.melonid = _os_.unmarshal_long();
        this.itemid = _os_.unmarshal_int();
        this.itemnum = _os_.unmarshal_int();
        this.itemdata = _os_.unmarshal_Octets();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RollMelon) {
            RollMelon _o_ = (RollMelon)_o1_;
            if (this.melonid != _o_.melonid) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.itemnum != _o_.itemnum) {
                return false;
            } else {
                return this.itemdata.equals(_o_.itemdata);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.melonid;
        _h_ += this.itemid;
        _h_ += this.itemnum;
        _h_ += this.itemdata.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonid).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemnum).append(",");
        _sb_.append("B").append(this.itemdata.size()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
