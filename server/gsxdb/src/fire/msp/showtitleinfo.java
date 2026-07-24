//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class showtitleinfo implements Marshal {
    public int titleid;
    public String titlename;
    public long validtime;

    public showtitleinfo() {
        this.titlename = "";
    }

    public showtitleinfo(int _titleid_, String _titlename_, long _validtime_) {
        this.titleid = _titleid_;
        this.titlename = _titlename_;
        this.validtime = _validtime_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.titleid);
        _os_.marshal(this.titlename, "UTF-16LE");
        _os_.marshal(this.validtime);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titleid = _os_.unmarshal_int();
        this.titlename = _os_.unmarshal_String("UTF-16LE");
        this.validtime = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof showtitleinfo) {
            showtitleinfo _o_ = (showtitleinfo)_o1_;
            if (this.titleid != _o_.titleid) {
                return false;
            } else if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else {
                return this.validtime == _o_.validtime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titleid;
        _h_ += this.titlename.hashCode();
        _h_ += (int)this.validtime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.titleid).append(",");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.validtime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
