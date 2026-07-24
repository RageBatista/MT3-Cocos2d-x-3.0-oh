//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetTeamState extends __SSetTeamState__ {
    public static final int PROTOCOL_TYPE = 794484;
    public int state;
    public int smapid;

    protected void process() {
    }

    public int getType() {
        return 794484;
    }

    public SSetTeamState() {
    }

    public SSetTeamState(int _state_, int _smapid_) {
        this.state = _state_;
        this.smapid = _smapid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.state);
            _os_.marshal(this.smapid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.state = _os_.unmarshal_int();
        this.smapid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetTeamState) {
            SSetTeamState _o_ = (SSetTeamState)_o1_;
            if (this.state != _o_.state) {
                return false;
            } else {
                return this.smapid == _o_.smapid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.state;
        _h_ += this.smapid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.state).append(",");
        _sb_.append(this.smapid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetTeamState _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.state - _o_.state;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.smapid - _o_.smapid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
