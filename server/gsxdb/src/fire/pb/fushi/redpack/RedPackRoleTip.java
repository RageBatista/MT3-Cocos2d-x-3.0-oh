//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi.redpack;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RedPackRoleTip implements Marshal {
    public int modeltype;
    public String redpackid;
    public String rolename;
    public int fushi;

    public RedPackRoleTip() {
        this.redpackid = "";
        this.rolename = "";
    }

    public RedPackRoleTip(int _modeltype_, String _redpackid_, String _rolename_, int _fushi_) {
        this.modeltype = _modeltype_;
        this.redpackid = _redpackid_;
        this.rolename = _rolename_;
        this.fushi = _fushi_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.modeltype);
        _os_.marshal(this.redpackid, "UTF-16LE");
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.fushi);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.modeltype = _os_.unmarshal_int();
        this.redpackid = _os_.unmarshal_String("UTF-16LE");
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.fushi = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RedPackRoleTip) {
            RedPackRoleTip _o_ = (RedPackRoleTip)_o1_;
            if (this.modeltype != _o_.modeltype) {
                return false;
            } else if (!this.redpackid.equals(_o_.redpackid)) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else {
                return this.fushi == _o_.fushi;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.modeltype;
        _h_ += this.redpackid.hashCode();
        _h_ += this.rolename.hashCode();
        _h_ += this.fushi;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.modeltype).append(",");
        _sb_.append("T").append(this.redpackid.length()).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.fushi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
