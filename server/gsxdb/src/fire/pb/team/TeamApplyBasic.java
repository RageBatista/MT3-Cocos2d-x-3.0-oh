//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class TeamApplyBasic implements Marshal {
    public long roleid;
    public String rolename;
    public int level;
    public int school;
    public String title;
    public int shape;
    public java.util.HashMap<Byte, Integer> components;

    public TeamApplyBasic() {
        this.rolename = "";
        this.title = "";
        this.components = new java.util.HashMap<Byte, Integer>();
    }

    public TeamApplyBasic(long _roleid_, String _rolename_, int _level_, int _school_, String _title_, int _shape_, java.util.HashMap<Byte, Integer> _components_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.level = _level_;
        this.school = _school_;
        this.title = _title_;
        this.shape = _shape_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.title, "UTF-16LE");
        _os_.marshal(this.shape);
        _os_.compact_uint32(this.components.size());

        for(java.util.Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal(_e_.getKey());
            _os_.marshal(_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.title = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TeamApplyBasic) {
            TeamApplyBasic _o_ = (TeamApplyBasic)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (!this.title.equals(_o_.title)) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else {
                return this.components.equals(_o_.components);
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
        _h_ += this.school;
        _h_ += this.title.hashCode();
        _h_ += this.shape;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append("T").append(this.title.length()).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
