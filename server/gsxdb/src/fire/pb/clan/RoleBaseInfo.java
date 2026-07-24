//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleBaseInfo implements Marshal {
    public long roleid;
    public String rolename;
    public int rolelevel;
    public int roleschool;
    public long applytime;
    public int fightvalue;

    public RoleBaseInfo() {
        this.rolename = "";
    }

    public RoleBaseInfo(long _roleid_, String _rolename_, int _rolelevel_, int _roleschool_, long _applytime_, int _fightvalue_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.rolelevel = _rolelevel_;
        this.roleschool = _roleschool_;
        this.applytime = _applytime_;
        this.fightvalue = _fightvalue_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.rolelevel);
        _os_.marshal(this.roleschool);
        _os_.marshal(this.applytime);
        _os_.marshal(this.fightvalue);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.rolelevel = _os_.unmarshal_int();
        this.roleschool = _os_.unmarshal_int();
        this.applytime = _os_.unmarshal_long();
        this.fightvalue = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleBaseInfo) {
            RoleBaseInfo _o_ = (RoleBaseInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.rolelevel != _o_.rolelevel) {
                return false;
            } else if (this.roleschool != _o_.roleschool) {
                return false;
            } else if (this.applytime != _o_.applytime) {
                return false;
            } else {
                return this.fightvalue == _o_.fightvalue;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.rolelevel;
        _h_ += this.roleschool;
        _h_ += (int)this.applytime;
        _h_ += this.fightvalue;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.rolelevel).append(",");
        _sb_.append(this.roleschool).append(",");
        _sb_.append(this.applytime).append(",");
        _sb_.append(this.fightvalue).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
