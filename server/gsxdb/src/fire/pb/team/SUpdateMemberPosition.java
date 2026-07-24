//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SUpdateMemberPosition extends __SUpdateMemberPosition__ {
    public static final int PROTOCOL_TYPE = 794471;
    public long roleid;
    public Pos1 position;
    public long sceneid;

    protected void process() {
    }

    public int getType() {
        return 794471;
    }

    public SUpdateMemberPosition() {
        this.position = new Pos1();
    }

    public SUpdateMemberPosition(long _roleid_, Pos1 _position_, long _sceneid_) {
        this.roleid = _roleid_;
        this.position = _position_;
        this.sceneid = _sceneid_;
    }

    public final boolean _validator_() {
        return this.position._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.position);
            _os_.marshal(this.sceneid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.position.unmarshal(_os_);
        this.sceneid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SUpdateMemberPosition) {
            SUpdateMemberPosition _o_ = (SUpdateMemberPosition)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.position.equals(_o_.position)) {
                return false;
            } else {
                return this.sceneid == _o_.sceneid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.position.hashCode();
        _h_ += (int)this.sceneid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.position).append(",");
        _sb_.append(this.sceneid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SUpdateMemberPosition _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.position.compareTo(_o_.position);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.sceneid - _o_.sceneid);
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
