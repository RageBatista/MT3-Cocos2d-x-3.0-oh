//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PrenticeData implements Marshal {
    public long roleid;
    public String rolename;
    public int flag;

    public PrenticeData() {
        this.rolename = "";
    }

    public PrenticeData(long _roleid_, String _rolename_, int _flag_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.flag = _flag_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.flag);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.flag = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PrenticeData) {
            PrenticeData _o_ = (PrenticeData)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else {
                return this.flag == _o_.flag;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.flag;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.flag).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
