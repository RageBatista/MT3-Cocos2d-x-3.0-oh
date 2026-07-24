//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi.redpack;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRRedPackNum implements Marshal, Comparable<SRRedPackNum> {
    public int modeltype;
    public int redpacksendnum;
    public int redpackreceivenum;
    public int redpackreceivefushinum;

    public SRRedPackNum() {
    }

    public SRRedPackNum(int _modeltype_, int _redpacksendnum_, int _redpackreceivenum_, int _redpackreceivefushinum_) {
        this.modeltype = _modeltype_;
        this.redpacksendnum = _redpacksendnum_;
        this.redpackreceivenum = _redpackreceivenum_;
        this.redpackreceivefushinum = _redpackreceivefushinum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.modeltype);
        _os_.marshal(this.redpacksendnum);
        _os_.marshal(this.redpackreceivenum);
        _os_.marshal(this.redpackreceivefushinum);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.modeltype = _os_.unmarshal_int();
        this.redpacksendnum = _os_.unmarshal_int();
        this.redpackreceivenum = _os_.unmarshal_int();
        this.redpackreceivefushinum = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRRedPackNum) {
            SRRedPackNum _o_ = (SRRedPackNum)_o1_;
            if (this.modeltype != _o_.modeltype) {
                return false;
            } else if (this.redpacksendnum != _o_.redpacksendnum) {
                return false;
            } else if (this.redpackreceivenum != _o_.redpackreceivenum) {
                return false;
            } else {
                return this.redpackreceivefushinum == _o_.redpackreceivefushinum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.modeltype;
        _h_ += this.redpacksendnum;
        _h_ += this.redpackreceivenum;
        _h_ += this.redpackreceivefushinum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.modeltype).append(",");
        _sb_.append(this.redpacksendnum).append(",");
        _sb_.append(this.redpackreceivenum).append(",");
        _sb_.append(this.redpackreceivefushinum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRRedPackNum _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.modeltype - _o_.modeltype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.redpacksendnum - _o_.redpacksendnum;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.redpackreceivenum - _o_.redpackreceivenum;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.redpackreceivefushinum - _o_.redpackreceivefushinum;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
