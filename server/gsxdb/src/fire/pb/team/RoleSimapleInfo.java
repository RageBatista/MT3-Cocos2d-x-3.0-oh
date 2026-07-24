//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleSimapleInfo implements Marshal {
    public String rolename;
    public int level;
    public long roleid;
    public int schoold;
    public int shape;

    public RoleSimapleInfo() {
        this.rolename = "";
    }

    public RoleSimapleInfo(String _rolename_, int _level_, long _roleid_, int _schoold_, int _shape_) {
        this.rolename = _rolename_;
        this.level = _level_;
        this.roleid = _roleid_;
        this.schoold = _schoold_;
        this.shape = _shape_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.roleid);
        _os_.marshal(this.schoold);
        _os_.marshal(this.shape);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.schoold = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleSimapleInfo) {
            RoleSimapleInfo _o_ = (RoleSimapleInfo)_o1_;
            if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.schoold != _o_.schoold) {
                return false;
            } else {
                return this.shape == _o_.shape;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rolename.hashCode();
        _h_ += this.level;
        _h_ += (int)this.roleid;
        _h_ += this.schoold;
        _h_ += this.shape;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.schoold).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
