//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleSimpleInfo implements Marshal {
    public long roleid;
    public String name;
    public int shape;
    public int school;
    public int level;
    public int camptype;

    public RoleSimpleInfo() {
        this.name = "";
    }

    public RoleSimpleInfo(long _roleid_, String _name_, int _shape_, int _school_, int _level_, int _camptype_) {
        this.roleid = _roleid_;
        this.name = _name_;
        this.shape = _shape_;
        this.school = _school_;
        this.level = _level_;
        this.camptype = _camptype_;
    }

    public final boolean _validator_() {
        return this.roleid > 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.shape);
        _os_.marshal(this.school);
        _os_.marshal(this.level);
        _os_.marshal(this.camptype);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.camptype = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleSimpleInfo) {
            RoleSimpleInfo _o_ = (RoleSimpleInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else {
                return this.camptype == _o_.camptype;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.name.hashCode();
        _h_ += this.shape;
        _h_ += this.school;
        _h_ += this.level;
        _h_ += this.camptype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.camptype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
