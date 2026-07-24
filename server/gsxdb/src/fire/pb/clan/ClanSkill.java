//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanSkill implements Marshal, Comparable<ClanSkill> {
    public int clanskillid;
    public int clanskilllevel;
    public int clanskillmaxlevel;
    public int clanskillcurexp;
    public int clanskilllevelupexp;

    public ClanSkill() {
    }

    public ClanSkill(int _clanskillid_, int _clanskilllevel_, int _clanskillmaxlevel_, int _clanskillcurexp_, int _clanskilllevelupexp_) {
        this.clanskillid = _clanskillid_;
        this.clanskilllevel = _clanskilllevel_;
        this.clanskillmaxlevel = _clanskillmaxlevel_;
        this.clanskillcurexp = _clanskillcurexp_;
        this.clanskilllevelupexp = _clanskilllevelupexp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.clanskillid);
        _os_.marshal(this.clanskilllevel);
        _os_.marshal(this.clanskillmaxlevel);
        _os_.marshal(this.clanskillcurexp);
        _os_.marshal(this.clanskilllevelupexp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.clanskillid = _os_.unmarshal_int();
        this.clanskilllevel = _os_.unmarshal_int();
        this.clanskillmaxlevel = _os_.unmarshal_int();
        this.clanskillcurexp = _os_.unmarshal_int();
        this.clanskilllevelupexp = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanSkill) {
            ClanSkill _o_ = (ClanSkill)_o1_;
            if (this.clanskillid != _o_.clanskillid) {
                return false;
            } else if (this.clanskilllevel != _o_.clanskilllevel) {
                return false;
            } else if (this.clanskillmaxlevel != _o_.clanskillmaxlevel) {
                return false;
            } else if (this.clanskillcurexp != _o_.clanskillcurexp) {
                return false;
            } else {
                return this.clanskilllevelupexp == _o_.clanskilllevelupexp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.clanskillid;
        _h_ += this.clanskilllevel;
        _h_ += this.clanskillmaxlevel;
        _h_ += this.clanskillcurexp;
        _h_ += this.clanskilllevelupexp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.clanskillid).append(",");
        _sb_.append(this.clanskilllevel).append(",");
        _sb_.append(this.clanskillmaxlevel).append(",");
        _sb_.append(this.clanskillcurexp).append(",");
        _sb_.append(this.clanskilllevelupexp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ClanSkill _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.clanskillid - _o_.clanskillid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.clanskilllevel - _o_.clanskilllevel;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.clanskillmaxlevel - _o_.clanskillmaxlevel;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.clanskillcurexp - _o_.clanskillcurexp;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.clanskilllevelupexp - _o_.clanskilllevelupexp;
                            return 0 != _c_ ? _c_ : _c_;
                        }
                    }
                }
            }
        }
    }
}
