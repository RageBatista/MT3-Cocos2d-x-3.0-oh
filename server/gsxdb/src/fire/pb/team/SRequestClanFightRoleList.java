//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SRequestClanFightRoleList extends __SRequestClanFightRoleList__ {
    public static final int PROTOCOL_TYPE = 794560;
    public int isfresh;
    public LinkedList<RoleSimapleInfo> rolelist;
    public int ret;

    protected void process() {
    }

    public int getType() {
        return 794560;
    }

    public SRequestClanFightRoleList() {
        this.rolelist = new LinkedList();
    }

    public SRequestClanFightRoleList(int _isfresh_, LinkedList<RoleSimapleInfo> _rolelist_, int _ret_) {
        this.isfresh = _isfresh_;
        this.rolelist = _rolelist_;
        this.ret = _ret_;
    }

    public final boolean _validator_() {
        for(RoleSimapleInfo _v_ : this.rolelist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.isfresh);
            _os_.compact_uint32(this.rolelist.size());

            for(RoleSimapleInfo _v_ : this.rolelist) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.ret);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.isfresh = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            RoleSimapleInfo _v_ = new RoleSimapleInfo();
            _v_.unmarshal(_os_);
            this.rolelist.add(_v_);
        }

        this.ret = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRequestClanFightRoleList) {
            SRequestClanFightRoleList _o_ = (SRequestClanFightRoleList)_o1_;
            if (this.isfresh != _o_.isfresh) {
                return false;
            } else if (!this.rolelist.equals(_o_.rolelist)) {
                return false;
            } else {
                return this.ret == _o_.ret;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.isfresh;
        _h_ += this.rolelist.hashCode();
        _h_ += this.ret;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.isfresh).append(",");
        _sb_.append(this.rolelist).append(",");
        _sb_.append(this.ret).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
