//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask.anye;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SubmitThing implements Marshal, Comparable<SubmitThing> {
    public int key;
    public int num;

    public SubmitThing() {
    }

    public SubmitThing(int _key_, int _num_) {
        this.key = _key_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        if (this.key <= 0) {
            return false;
        } else {
            return this.num > 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.key);
        _os_.marshal(this.num);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.key = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SubmitThing) {
            SubmitThing _o_ = (SubmitThing)_o1_;
            if (this.key != _o_.key) {
                return false;
            } else {
                return this.num == _o_.num;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.key;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.key).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SubmitThing _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.key - _o_.key;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num - _o_.num;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
