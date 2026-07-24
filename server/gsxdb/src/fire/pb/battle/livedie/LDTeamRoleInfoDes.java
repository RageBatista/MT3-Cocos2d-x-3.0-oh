//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle.livedie;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class LDTeamRoleInfoDes implements Marshal {
    public long roleid;
    public String rolename;
    public int shape;
    public int level;
    public int school;

    public LDTeamRoleInfoDes() {
        this.rolename = "";
    }

    public LDTeamRoleInfoDes(long _roleid_, String _rolename_, int _shape_, int _level_, int _school_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.shape = _shape_;
        this.level = _level_;
        this.school = _school_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.shape);
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LDTeamRoleInfoDes) {
            LDTeamRoleInfoDes _o_ = (LDTeamRoleInfoDes)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.level != _o_.level) {
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
        _h_ += this.rolename.hashCode();
        _h_ += this.shape;
        _h_ += this.level;
        _h_ += this.school;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
