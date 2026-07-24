//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanEventInfo implements Marshal {
    public String eventtime;
    public String eventinfo;
    public int eventtype;
    public long eventvalue;

    public ClanEventInfo() {
        this.eventtime = "";
        this.eventinfo = "";
    }

    public ClanEventInfo(String _eventtime_, String _eventinfo_, int _eventtype_, long _eventvalue_) {
        this.eventtime = _eventtime_;
        this.eventinfo = _eventinfo_;
        this.eventtype = _eventtype_;
        this.eventvalue = _eventvalue_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.eventtime, "UTF-16LE");
        _os_.marshal(this.eventinfo, "UTF-16LE");
        _os_.marshal(this.eventtype);
        _os_.marshal(this.eventvalue);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.eventtime = _os_.unmarshal_String("UTF-16LE");
        this.eventinfo = _os_.unmarshal_String("UTF-16LE");
        this.eventtype = _os_.unmarshal_int();
        this.eventvalue = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanEventInfo) {
            ClanEventInfo _o_ = (ClanEventInfo)_o1_;
            if (!this.eventtime.equals(_o_.eventtime)) {
                return false;
            } else if (!this.eventinfo.equals(_o_.eventinfo)) {
                return false;
            } else if (this.eventtype != _o_.eventtype) {
                return false;
            } else {
                return this.eventvalue == _o_.eventvalue;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.eventtime.hashCode();
        _h_ += this.eventinfo.hashCode();
        _h_ += this.eventtype;
        _h_ += (int)this.eventvalue;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.eventtime.length()).append(",");
        _sb_.append("T").append(this.eventinfo.length()).append(",");
        _sb_.append(this.eventtype).append(",");
        _sb_.append(this.eventvalue).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
