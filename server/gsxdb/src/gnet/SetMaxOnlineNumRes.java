//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SetMaxOnlineNumRes implements Marshal, Comparable<SetMaxOnlineNumRes> {
    public int retcode;

    public SetMaxOnlineNumRes() {
    }

    public SetMaxOnlineNumRes(int _retcode_) {
        this.retcode = _retcode_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.retcode);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.retcode = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SetMaxOnlineNumRes) {
            SetMaxOnlineNumRes _o_ = (SetMaxOnlineNumRes)_o1_;
            return this.retcode == _o_.retcode;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.retcode;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.retcode).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SetMaxOnlineNumRes _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.retcode - _o_.retcode;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
