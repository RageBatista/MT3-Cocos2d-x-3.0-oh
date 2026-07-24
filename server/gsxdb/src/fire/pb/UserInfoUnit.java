//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class UserInfoUnit implements Marshal {
    public String key;
    public String value;

    public UserInfoUnit() {
        this.key = "";
        this.value = "";
    }

    public UserInfoUnit(String _key_, String _value_) {
        this.key = _key_;
        this.value = _value_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.key, "UTF-16LE");
        _os_.marshal(this.value, "UTF-16LE");
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.key = _os_.unmarshal_String("UTF-16LE");
        this.value = _os_.unmarshal_String("UTF-16LE");
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof UserInfoUnit) {
            UserInfoUnit _o_ = (UserInfoUnit)_o1_;
            if (!this.key.equals(_o_.key)) {
                return false;
            } else {
                return this.value.equals(_o_.value);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.key.hashCode();
        _h_ += this.value.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.key.length()).append(",");
        _sb_.append("T").append(this.value.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
