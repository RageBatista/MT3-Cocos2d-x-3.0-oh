//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi.redpack;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RedPackInfo implements Marshal {
    public String redpackid;
    public long roleid;
    public String rolename;
    public String redpackdes;
    public int redpackstate;
    public int fushi;

    public RedPackInfo() {
        this.redpackid = "";
        this.rolename = "";
        this.redpackdes = "";
    }

    public RedPackInfo(String _redpackid_, long _roleid_, String _rolename_, String _redpackdes_, int _redpackstate_, int _fushi_) {
        this.redpackid = _redpackid_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.redpackdes = _redpackdes_;
        this.redpackstate = _redpackstate_;
        this.fushi = _fushi_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.redpackid, "UTF-16LE");
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.redpackdes, "UTF-16LE");
        _os_.marshal(this.redpackstate);
        _os_.marshal(this.fushi);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.redpackid = _os_.unmarshal_String("UTF-16LE");
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.redpackdes = _os_.unmarshal_String("UTF-16LE");
        this.redpackstate = _os_.unmarshal_int();
        this.fushi = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RedPackInfo) {
            RedPackInfo _o_ = (RedPackInfo)_o1_;
            if (!this.redpackid.equals(_o_.redpackid)) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (!this.redpackdes.equals(_o_.redpackdes)) {
                return false;
            } else if (this.redpackstate != _o_.redpackstate) {
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
        _h_ += this.redpackid.hashCode();
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.redpackdes.hashCode();
        _h_ += this.redpackstate;
        _h_ += this.fushi;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.redpackid.length()).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append("T").append(this.redpackdes.length()).append(",");
        _sb_.append(this.redpackstate).append(",");
        _sb_.append(this.fushi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
