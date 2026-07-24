//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle.pvp3;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PvP3RoleSingleMatch implements Marshal, Comparable<PvP3RoleSingleMatch> {
    public long roleid;
    public short level;
    public int shape;
    public int school;

    public PvP3RoleSingleMatch() {
    }

    public PvP3RoleSingleMatch(long _roleid_, short _level_, int _shape_, int _school_) {
        this.roleid = _roleid_;
        this.level = _level_;
        this.shape = _shape_;
        this.school = _school_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.level);
        _os_.marshal(this.shape);
        _os_.marshal(this.school);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.level = _os_.unmarshal_short();
        this.shape = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PvP3RoleSingleMatch) {
            PvP3RoleSingleMatch _o_ = (PvP3RoleSingleMatch)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else {
                return this.school == _o_.school;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.level;
        _h_ += this.shape;
        _h_ += this.school;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(PvP3RoleSingleMatch _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.level - _o_.level;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.shape - _o_.shape;
                    if (_c_ != 0) {
                        return _c_;
                    } else {
                        _c_ = this.school - _o_.school;
                        return _c_ != 0 ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
