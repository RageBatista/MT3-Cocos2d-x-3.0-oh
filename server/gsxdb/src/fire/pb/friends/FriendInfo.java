//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FriendInfo implements Marshal {
    public InfoBean friendinfobean;
    public int friendlevel;

    public FriendInfo() {
        this.friendinfobean = new InfoBean();
    }

    public FriendInfo(InfoBean _friendinfobean_, int _friendlevel_) {
        this.friendinfobean = _friendinfobean_;
        this.friendlevel = _friendlevel_;
    }

    public final boolean _validator_() {
        if (!this.friendinfobean._validator_()) {
            return false;
        } else {
            return this.friendlevel >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.friendinfobean);
        _os_.marshal(this.friendlevel);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.friendinfobean.unmarshal(_os_);
        this.friendlevel = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FriendInfo) {
            FriendInfo _o_ = (FriendInfo)_o1_;
            if (!this.friendinfobean.equals(_o_.friendinfobean)) {
                return false;
            } else {
                return this.friendlevel == _o_.friendlevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.friendinfobean.hashCode();
        _h_ += this.friendlevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.friendinfobean).append(",");
        _sb_.append(this.friendlevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
