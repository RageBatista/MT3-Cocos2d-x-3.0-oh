//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TeamInfoOctets implements Marshal, Comparable<TeamInfoOctets> {
    public long teamid;
    public byte teamindexstate;
    public byte hugindex;
    public byte normalnum;

    public TeamInfoOctets() {
    }

    public TeamInfoOctets(long _teamid_, byte _teamindexstate_, byte _hugindex_, byte _normalnum_) {
        this.teamid = _teamid_;
        this.teamindexstate = _teamindexstate_;
        this.hugindex = _hugindex_;
        this.normalnum = _normalnum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.teamid);
        _os_.marshal(this.teamindexstate);
        _os_.marshal(this.hugindex);
        _os_.marshal(this.normalnum);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        this.teamindexstate = _os_.unmarshal_byte();
        this.hugindex = _os_.unmarshal_byte();
        this.normalnum = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TeamInfoOctets) {
            TeamInfoOctets _o_ = (TeamInfoOctets)_o1_;
            if (this.teamid != _o_.teamid) {
                return false;
            } else if (this.teamindexstate != _o_.teamindexstate) {
                return false;
            } else if (this.hugindex != _o_.hugindex) {
                return false;
            } else {
                return this.normalnum == _o_.normalnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.teamid;
        _h_ += this.teamindexstate;
        _h_ += this.hugindex;
        _h_ += this.normalnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(this.teamindexstate).append(",");
        _sb_.append(this.hugindex).append(",");
        _sb_.append(this.normalnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(TeamInfoOctets _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.teamid - _o_.teamid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.teamindexstate - _o_.teamindexstate;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.hugindex - _o_.hugindex;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.normalnum - _o_.normalnum;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
