//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Pos1 implements Marshal, Comparable<Pos1> {
    public int x;
    public int y;

    public Pos1() {
    }

    public Pos1(int _x_, int _y_) {
        this.x = _x_;
        this.y = _y_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.x);
        _os_.marshal(this.y);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.x = _os_.unmarshal_int();
        this.y = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Pos1) {
            Pos1 _o_ = (Pos1)_o1_;
            if (this.x != _o_.x) {
                return false;
            } else {
                return this.y == _o_.y;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.x;
        _h_ += this.y;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.x).append(",");
        _sb_.append(this.y).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Pos1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.x - _o_.x;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.y - _o_.y;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
