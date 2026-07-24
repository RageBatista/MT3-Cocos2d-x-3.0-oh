//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRemovePetFromCol extends __SRemovePetFromCol__ {
    public static final int PROTOCOL_TYPE = 788445;
    public int columnid;
    public int petkey;

    protected void process() {
    }

    public int getType() {
        return 788445;
    }

    public SRemovePetFromCol() {
    }

    public SRemovePetFromCol(int _columnid_, int _petkey_) {
        this.columnid = _columnid_;
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        if (this.columnid < 1) {
            return false;
        } else {
            return this.petkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.columnid);
            _os_.marshal(this.petkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.columnid = _os_.unmarshal_int();
        this.petkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRemovePetFromCol) {
            SRemovePetFromCol _o_ = (SRemovePetFromCol)_o1_;
            if (this.columnid != _o_.columnid) {
                return false;
            } else {
                return this.petkey == _o_.petkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.columnid;
        _h_ += this.petkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.columnid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRemovePetFromCol _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.columnid - _o_.columnid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.petkey - _o_.petkey;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
