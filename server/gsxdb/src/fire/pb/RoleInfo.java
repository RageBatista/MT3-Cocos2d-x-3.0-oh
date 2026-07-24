//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class RoleInfo implements Marshal {
    public long roleid;
    public String rolename;
    public int school;
    public int shape;
    public int level;
    public java.util.HashMap<Byte, Integer> components;
    public long rolecreatetime;

    public RoleInfo() {
        this.rolename = "";
        this.components = new java.util.HashMap<Byte, Integer>();
    }

    public RoleInfo(long _roleid_, String _rolename_, int _school_, int _shape_, int _level_, java.util.HashMap<Byte, Integer> _components_, long _rolecreatetime_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.school = _school_;
        this.shape = _shape_;
        this.level = _level_;
        this.components = _components_;
        this.rolecreatetime = _rolecreatetime_;
    }

    public final boolean _validator_() {
        if (this.roleid < 1L) {
            return false;
        } else {
            return this.level >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.school);
        _os_.marshal(this.shape);
        _os_.marshal(this.level);
        _os_.compact_uint32(this.components.size());

        for(java.util.Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal(_e_.getKey());
            _os_.marshal(_e_.getValue());
        }

        _os_.marshal(this.rolecreatetime);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.school = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        this.rolecreatetime = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleInfo) {
            RoleInfo _o_ = (RoleInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (!this.components.equals(_o_.components)) {
                return false;
            } else {
                return this.rolecreatetime == _o_.rolecreatetime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.school;
        _h_ += this.shape;
        _h_ += this.level;
        _h_ += this.components.hashCode();
        _h_ += (int)this.rolecreatetime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(this.rolecreatetime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
