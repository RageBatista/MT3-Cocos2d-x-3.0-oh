//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SShowPetAround extends __SShowPetAround__ {
    public static final int PROTOCOL_TYPE = 788434;
    public long roleid;
    public int showpetkey;
    public int showpetid;
    public String showpetname;
    public byte colour;
    public byte size;
    public byte showeffect;

    protected void process() {
    }

    public int getType() {
        return 788434;
    }

    public SShowPetAround() {
        this.showpetname = "";
    }

    public SShowPetAround(long _roleid_, int _showpetkey_, int _showpetid_, String _showpetname_, byte _colour_, byte _size_, byte _showeffect_) {
        this.roleid = _roleid_;
        this.showpetkey = _showpetkey_;
        this.showpetid = _showpetid_;
        this.showpetname = _showpetname_;
        this.colour = _colour_;
        this.size = _size_;
        this.showeffect = _showeffect_;
    }

    public final boolean _validator_() {
        if (this.roleid <= 0L) {
            return false;
        } else if (this.showpetkey < 0) {
            return false;
        } else if (this.showpetid < 0) {
            return false;
        } else if (this.colour < 0) {
            return false;
        } else if (this.size < 0) {
            return false;
        } else {
            return this.showeffect >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.showpetkey);
            _os_.marshal(this.showpetid);
            _os_.marshal(this.showpetname, "UTF-16LE");
            _os_.marshal(this.colour);
            _os_.marshal(this.size);
            _os_.marshal(this.showeffect);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.showpetkey = _os_.unmarshal_int();
        this.showpetid = _os_.unmarshal_int();
        this.showpetname = _os_.unmarshal_String("UTF-16LE");
        this.colour = _os_.unmarshal_byte();
        this.size = _os_.unmarshal_byte();
        this.showeffect = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SShowPetAround) {
            SShowPetAround _o_ = (SShowPetAround)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.showpetkey != _o_.showpetkey) {
                return false;
            } else if (this.showpetid != _o_.showpetid) {
                return false;
            } else if (!this.showpetname.equals(_o_.showpetname)) {
                return false;
            } else if (this.colour != _o_.colour) {
                return false;
            } else if (this.size != _o_.size) {
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
        _h_ += (int)this.roleid;
        _h_ += this.showpetkey;
        _h_ += this.showpetid;
        _h_ += this.showpetname.hashCode();
        _h_ += this.colour;
        _h_ += this.size;
        _h_ += this.showeffect;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.showpetkey).append(",");
        _sb_.append(this.showpetid).append(",");
        _sb_.append("T").append(this.showpetname.length()).append(",");
        _sb_.append(this.colour).append(",");
        _sb_.append(this.size).append(",");
        _sb_.append(this.showeffect).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
