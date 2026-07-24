//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle.livedie;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class LDRoleInfoDes implements Marshal {
    public long roleid;
    public String rolename;
    public int shape;
    public int level;
    public int school;
    public int teamnum;
    public int teamnummax;

    public LDRoleInfoDes() {
        this.rolename = "";
    }

    public LDRoleInfoDes(long _roleid_, String _rolename_, int _shape_, int _level_, int _school_, int _teamnum_, int _teamnummax_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.shape = _shape_;
        this.level = _level_;
        this.school = _school_;
        this.teamnum = _teamnum_;
        this.teamnummax = _teamnummax_;
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
        _os_.marshal(this.teamnum);
        _os_.marshal(this.teamnummax);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.teamnum = _os_.unmarshal_int();
        this.teamnummax = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LDRoleInfoDes) {
            LDRoleInfoDes _o_ = (LDRoleInfoDes)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.teamnum != _o_.teamnum) {
                return false;
            } else {
                return this.teamnummax == _o_.teamnummax;
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
        _h_ += this.teamnum;
        _h_ += this.teamnummax;
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
        _sb_.append(this.teamnum).append(",");
        _sb_.append(this.teamnummax).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
