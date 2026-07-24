//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class showpetinfo implements Marshal {
    public int petid;
    public long petkey;
    public String petname;
    public int color;
    public int bodysize;
    public int showeffect;

    public showpetinfo() {
        this.petname = "";
    }

    public showpetinfo(int _petid_, long _petkey_, String _petname_, int _color_, int _bodysize_, int _showeffect_) {
        this.petid = _petid_;
        this.petkey = _petkey_;
        this.petname = _petname_;
        this.color = _color_;
        this.bodysize = _bodysize_;
        this.showeffect = _showeffect_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.petid);
        _os_.marshal(this.petkey);
        _os_.marshal(this.petname, "UTF-16LE");
        _os_.marshal(this.color);
        _os_.marshal(this.bodysize);
        _os_.marshal(this.showeffect);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petid = _os_.unmarshal_int();
        this.petkey = _os_.unmarshal_long();
        this.petname = _os_.unmarshal_String("UTF-16LE");
        this.color = _os_.unmarshal_int();
        this.bodysize = _os_.unmarshal_int();
        this.showeffect = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof showpetinfo) {
            showpetinfo _o_ = (showpetinfo)_o1_;
            if (this.petid != _o_.petid) {
                return false;
            } else if (this.petkey != _o_.petkey) {
                return false;
            } else if (!this.petname.equals(_o_.petname)) {
                return false;
            } else if (this.color != _o_.color) {
                return false;
            } else if (this.bodysize != _o_.bodysize) {
                return false;
            } else {
                return this.showeffect == _o_.showeffect;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petid;
        _h_ += (int)this.petkey;
        _h_ += this.petname.hashCode();
        _h_ += this.color;
        _h_ += this.bodysize;
        _h_ += this.showeffect;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append("T").append(this.petname.length()).append(",");
        _sb_.append(this.color).append(",");
        _sb_.append(this.bodysize).append(",");
        _sb_.append(this.showeffect).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
