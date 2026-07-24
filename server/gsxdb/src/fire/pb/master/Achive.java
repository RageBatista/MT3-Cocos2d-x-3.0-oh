//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Achive implements Marshal, Comparable<Achive> {
    public int currnumber;
    public int totalnum;
    public int flag;

    public Achive() {
    }

    public Achive(int _currnumber_, int _totalnum_, int _flag_) {
        this.currnumber = _currnumber_;
        this.totalnum = _totalnum_;
        this.flag = _flag_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.currnumber);
        _os_.marshal(this.totalnum);
        _os_.marshal(this.flag);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.currnumber = _os_.unmarshal_int();
        this.totalnum = _os_.unmarshal_int();
        this.flag = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Achive) {
            Achive _o_ = (Achive)_o1_;
            if (this.currnumber != _o_.currnumber) {
                return false;
            } else if (this.totalnum != _o_.totalnum) {
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
        _h_ += this.currnumber;
        _h_ += this.totalnum;
        _h_ += this.flag;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.currnumber).append(",");
        _sb_.append(this.totalnum).append(",");
        _sb_.append(this.flag).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Achive _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.currnumber - _o_.currnumber;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.totalnum - _o_.totalnum;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.flag - _o_.flag;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
