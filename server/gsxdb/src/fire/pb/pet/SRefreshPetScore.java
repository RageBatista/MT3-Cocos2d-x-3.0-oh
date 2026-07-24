//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRefreshPetScore extends __SRefreshPetScore__ {
    public static final int PROTOCOL_TYPE = 788511;
    public int petkey;
    public int petscore;
    public int petbasescore;

    protected void process() {
    }

    public int getType() {
        return 788511;
    }

    public SRefreshPetScore() {
    }

    public SRefreshPetScore(int _petkey_, int _petscore_, int _petbasescore_) {
        this.petkey = _petkey_;
        this.petscore = _petscore_;
        this.petbasescore = _petbasescore_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.petscore);
            _os_.marshal(this.petbasescore);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.petscore = _os_.unmarshal_int();
        this.petbasescore = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRefreshPetScore) {
            SRefreshPetScore _o_ = (SRefreshPetScore)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.petscore != _o_.petscore) {
                return false;
            } else {
                return this.petbasescore == _o_.petbasescore;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.petscore;
        _h_ += this.petbasescore;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.petscore).append(",");
        _sb_.append(this.petbasescore).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRefreshPetScore _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.petscore - _o_.petscore;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.petbasescore - _o_.petbasescore;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
