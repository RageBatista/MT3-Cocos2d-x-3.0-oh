//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SModPetName extends __SModPetName__ {
    public static final int PROTOCOL_TYPE = 788451;
    public long roleid;
    public int petkey;
    public String petname;

    protected void process() {
    }

    public int getType() {
        return 788451;
    }

    public SModPetName() {
        this.petname = "";
    }

    public SModPetName(long _roleid_, int _petkey_, String _petname_) {
        this.roleid = _roleid_;
        this.petkey = _petkey_;
        this.petname = _petname_;
    }

    public final boolean _validator_() {
        if (this.roleid < 1L) {
            return false;
        } else {
            return this.petkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.petkey);
            _os_.marshal(this.petname, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.petkey = _os_.unmarshal_int();
        this.petname = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SModPetName) {
            SModPetName _o_ = (SModPetName)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.petname.equals(_o_.petname);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.petkey;
        _h_ += this.petname.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append("T").append(this.petname.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
