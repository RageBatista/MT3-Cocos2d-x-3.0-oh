//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SUpdateMemberLevel extends __SUpdateMemberLevel__ {
    public static final int PROTOCOL_TYPE = 794459;
    public long roleid;
    public int level;

    protected void process() {
    }

    public int getType() {
        return 794459;
    }

    public SUpdateMemberLevel() {
    }

    public SUpdateMemberLevel(long _roleid_, int _level_) {
        this.roleid = _roleid_;
        this.level = _level_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.level);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.level = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SUpdateMemberLevel) {
            SUpdateMemberLevel _o_ = (SUpdateMemberLevel)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.level == _o_.level;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.level;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SUpdateMemberLevel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.level - _o_.level;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
