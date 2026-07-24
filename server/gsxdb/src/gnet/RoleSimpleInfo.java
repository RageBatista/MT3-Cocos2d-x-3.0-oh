//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleSimpleInfo implements Marshal {
    public long roleid;
    public Octets rolename;
    public int level;

    public RoleSimpleInfo() {
        this.rolename = new Octets();
    }

    public RoleSimpleInfo(long _roleid_, Octets _rolename_, int _level_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.level = _level_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename);
        _os_.marshal(this.level);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_Octets();
        this.level = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleSimpleInfo) {
            RoleSimpleInfo _o_ = (RoleSimpleInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
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
        _h_ += this.rolename.hashCode();
        _h_ += this.level;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("B").append(this.rolename.size()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
