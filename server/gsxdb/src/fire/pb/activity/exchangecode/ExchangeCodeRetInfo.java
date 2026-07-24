//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.activity.exchangecode;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ExchangeCodeRetInfo implements Marshal {
    public int itemtype;
    public long itemid;
    public int itemcount;
    public String preinfos;

    public ExchangeCodeRetInfo() {
        this.preinfos = "";
    }

    public ExchangeCodeRetInfo(int _itemtype_, long _itemid_, int _itemcount_, String _preinfos_) {
        this.itemtype = _itemtype_;
        this.itemid = _itemid_;
        this.itemcount = _itemcount_;
        this.preinfos = _preinfos_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemtype);
        _os_.marshal(this.itemid);
        _os_.marshal(this.itemcount);
        _os_.marshal(this.preinfos, "UTF-16LE");
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemtype = _os_.unmarshal_int();
        this.itemid = _os_.unmarshal_long();
        this.itemcount = _os_.unmarshal_int();
        this.preinfos = _os_.unmarshal_String("UTF-16LE");
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ExchangeCodeRetInfo) {
            ExchangeCodeRetInfo _o_ = (ExchangeCodeRetInfo)_o1_;
            if (this.itemtype != _o_.itemtype) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.itemcount != _o_.itemcount ? false : this.preinfos.equals(_o_.preinfos);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemtype;
        _h_ += (int)this.itemid;
        _h_ += this.itemcount;
        _h_ += this.preinfos.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemtype).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemcount).append(",");
        _sb_.append("T").append(this.preinfos.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
