//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class UseFormBook implements Marshal, Comparable<UseFormBook> {
    public int bookid;
    public int num;

    public UseFormBook() {
    }

    public UseFormBook(int _bookid_, int _num_) {
        this.bookid = _bookid_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.bookid);
        _os_.marshal(this.num);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.bookid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof UseFormBook) {
            UseFormBook _o_ = (UseFormBook)_o1_;
            if (this.bookid != _o_.bookid) {
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
        _h_ += this.bookid;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.bookid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(UseFormBook _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.bookid - _o_.bookid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num - _o_.num;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
