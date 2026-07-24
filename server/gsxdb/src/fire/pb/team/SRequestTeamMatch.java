//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRequestTeamMatch extends __SRequestTeamMatch__ {
    public static final int PROTOCOL_TYPE = 794495;
    public int typematch;
    public int targetid;
    public int levelmin;
    public int levelmax;

    protected void process() {
    }

    public int getType() {
        return 794495;
    }

    public SRequestTeamMatch() {
    }

    public SRequestTeamMatch(int _typematch_, int _targetid_, int _levelmin_, int _levelmax_) {
        this.typematch = _typematch_;
        this.targetid = _targetid_;
        this.levelmin = _levelmin_;
        this.levelmax = _levelmax_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.typematch);
            _os_.marshal(this.targetid);
            _os_.marshal(this.levelmin);
            _os_.marshal(this.levelmax);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.typematch = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();
        this.levelmin = _os_.unmarshal_int();
        this.levelmax = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRequestTeamMatch) {
            SRequestTeamMatch _o_ = (SRequestTeamMatch)_o1_;
            if (this.typematch != _o_.typematch) {
                return false;
            } else if (this.targetid != _o_.targetid) {
                return false;
            } else if (this.levelmin != _o_.levelmin) {
                return false;
            } else {
                return this.levelmax == _o_.levelmax;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.typematch;
        _h_ += this.targetid;
        _h_ += this.levelmin;
        _h_ += this.levelmax;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.typematch).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.levelmin).append(",");
        _sb_.append(this.levelmax).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRequestTeamMatch _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.typematch - _o_.typematch;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.targetid - _o_.targetid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.levelmin - _o_.levelmin;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.levelmax - _o_.levelmax;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
