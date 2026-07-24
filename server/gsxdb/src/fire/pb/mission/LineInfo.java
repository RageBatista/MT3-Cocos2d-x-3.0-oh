//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class LineInfo implements Marshal, Comparable<LineInfo> {
    public int id;
    public int state;
    public int finish;

    public LineInfo() {
    }

    public LineInfo(int _id_, int _state_, int _finish_) {
        this.id = _id_;
        this.state = _state_;
        this.finish = _finish_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.state);
        _os_.marshal(this.finish);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        this.finish = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LineInfo) {
            LineInfo _o_ = (LineInfo)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else {
                return this.finish == _o_.finish;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.state;
        _h_ += this.finish;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.finish).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(LineInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.id - _o_.id;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.state - _o_.state;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.finish - _o_.finish;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
