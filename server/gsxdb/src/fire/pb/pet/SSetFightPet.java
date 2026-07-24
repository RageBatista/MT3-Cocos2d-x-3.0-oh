//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetFightPet extends __SSetFightPet__ {
    public static final int PROTOCOL_TYPE = 788441;
    public int petkey;
    public byte isinbattle;

    protected void process() {
    }

    public int getType() {
        return 788441;
    }

    public SSetFightPet() {
    }

    public SSetFightPet(int _petkey_, byte _isinbattle_) {
        this.petkey = _petkey_;
        this.isinbattle = _isinbattle_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.isinbattle >= 0 && this.isinbattle <= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.isinbattle);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.isinbattle = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetFightPet) {
            SSetFightPet _o_ = (SSetFightPet)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.isinbattle == _o_.isinbattle;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.isinbattle;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.isinbattle).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetFightPet _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.isinbattle - _o_.isinbattle;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
