//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SetMaxOnlineNumArg implements Marshal, Comparable<SetMaxOnlineNumArg> {
    public int maxnum;
    public int fake_maxnum;

    public SetMaxOnlineNumArg() {
    }

    public SetMaxOnlineNumArg(int _maxnum_, int _fake_maxnum_) {
        this.maxnum = _maxnum_;
        this.fake_maxnum = _fake_maxnum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.maxnum);
        _os_.marshal(this.fake_maxnum);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.maxnum = _os_.unmarshal_int();
        this.fake_maxnum = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SetMaxOnlineNumArg) {
            SetMaxOnlineNumArg _o_ = (SetMaxOnlineNumArg)_o1_;
            if (this.maxnum != _o_.maxnum) {
                return false;
            } else {
                return this.fake_maxnum == _o_.fake_maxnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.maxnum;
        _h_ += this.fake_maxnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.maxnum).append(",");
        _sb_.append(this.fake_maxnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SetMaxOnlineNumArg _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.maxnum - _o_.maxnum;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.fake_maxnum - _o_.fake_maxnum;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
