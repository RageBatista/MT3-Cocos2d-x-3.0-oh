//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pingbi;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BlackRoleInfo implements Marshal {
    public long roleid;
    public String name;
    public short level;
    public int shape;
    public byte school;

    public BlackRoleInfo() {
        this.name = "";
    }

    public BlackRoleInfo(long _roleid_, String _name_, short _level_, int _shape_, byte _school_) {
        this.roleid = _roleid_;
        this.name = _name_;
        this.level = _level_;
        this.shape = _shape_;
        this.school = _school_;
    }

    public final boolean _validator_() {
        return this.roleid >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.shape);
        _os_.marshal(this.school);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_short();
        this.shape = _os_.unmarshal_int();
        this.school = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof BlackRoleInfo) {
            BlackRoleInfo _o_ = (BlackRoleInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
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
        _h_ += this.name.hashCode();
        _h_ += this.level;
        _h_ += this.shape;
        _h_ += this.school;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
