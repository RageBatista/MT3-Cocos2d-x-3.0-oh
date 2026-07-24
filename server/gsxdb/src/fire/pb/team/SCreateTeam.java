//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SCreateTeam extends __SCreateTeam__ {
    public static final int PROTOCOL_TYPE = 794434;
    public long teamid;
    public int formation;
    public int teamstate;
    public int smapid;

    protected void process() {
    }

    public int getType() {
        return 794434;
    }

    public SCreateTeam() {
    }

    public SCreateTeam(long _teamid_, int _formation_, int _teamstate_, int _smapid_) {
        this.teamid = _teamid_;
        this.formation = _formation_;
        this.teamstate = _teamstate_;
        this.smapid = _smapid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teamid);
            _os_.marshal(this.formation);
            _os_.marshal(this.teamstate);
            _os_.marshal(this.smapid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        this.formation = _os_.unmarshal_int();
        this.teamstate = _os_.unmarshal_int();
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
        } else if (_o1_ instanceof SCreateTeam) {
            SCreateTeam _o_ = (SCreateTeam)_o1_;
            if (this.teamid != _o_.teamid) {
                return false;
            } else if (this.formation != _o_.formation) {
                return false;
            } else if (this.teamstate != _o_.teamstate) {
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
        _h_ += (int)this.teamid;
        _h_ += this.formation;
        _h_ += this.teamstate;
        _h_ += this.smapid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(this.formation).append(",");
        _sb_.append(this.teamstate).append(",");
        _sb_.append(this.smapid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SCreateTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.teamid - _o_.teamid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.formation - _o_.formation;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.teamstate - _o_.teamstate;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.smapid - _o_.smapid;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
