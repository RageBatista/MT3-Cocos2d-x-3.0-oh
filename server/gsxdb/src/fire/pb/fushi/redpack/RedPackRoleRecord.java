//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi.redpack;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RedPackRoleRecord implements Marshal {
    public int modeltype;
    public String redpackid;
    public long roleid;
    public String rolename;
    public int school;
    public int shape;
    public int redpackmoney;
    public long time;

    public RedPackRoleRecord() {
        this.redpackid = "";
        this.rolename = "";
    }

    public RedPackRoleRecord(int _modeltype_, String _redpackid_, long _roleid_, String _rolename_, int _school_, int _shape_, int _redpackmoney_, long _time_) {
        this.modeltype = _modeltype_;
        this.redpackid = _redpackid_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.school = _school_;
        this.shape = _shape_;
        this.redpackmoney = _redpackmoney_;
        this.time = _time_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.modeltype);
        _os_.marshal(this.redpackid, "UTF-16LE");
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.school);
        _os_.marshal(this.shape);
        _os_.marshal(this.redpackmoney);
        _os_.marshal(this.time);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.modeltype = _os_.unmarshal_int();
        this.redpackid = _os_.unmarshal_String("UTF-16LE");
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.school = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.redpackmoney = _os_.unmarshal_int();
        this.time = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RedPackRoleRecord) {
            RedPackRoleRecord _o_ = (RedPackRoleRecord)_o1_;
            if (this.modeltype != _o_.modeltype) {
                return false;
            } else if (!this.redpackid.equals(_o_.redpackid)) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.redpackmoney != _o_.redpackmoney) {
                return false;
            } else {
                return this.time == _o_.time;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.modeltype;
        _h_ += this.redpackid.hashCode();
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.school;
        _h_ += this.shape;
        _h_ += this.redpackmoney;
        _h_ += (int)this.time;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.modeltype).append(",");
        _sb_.append("T").append(this.redpackid.length()).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.redpackmoney).append(",");
        _sb_.append(this.time).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
