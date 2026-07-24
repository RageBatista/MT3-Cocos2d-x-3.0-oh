//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class AIOperation implements Marshal, Comparable<AIOperation> {
    public int actionseq;
    public int actionmoment;
    public int actionfighterid;
    public int actionid;

    public AIOperation() {
    }

    public AIOperation(int _actionseq_, int _actionmoment_, int _actionfighterid_, int _actionid_) {
        this.actionseq = _actionseq_;
        this.actionmoment = _actionmoment_;
        this.actionfighterid = _actionfighterid_;
        this.actionid = _actionid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.actionseq);
        _os_.marshal(this.actionmoment);
        _os_.marshal(this.actionfighterid);
        _os_.marshal(this.actionid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.actionseq = _os_.unmarshal_int();
        this.actionmoment = _os_.unmarshal_int();
        this.actionfighterid = _os_.unmarshal_int();
        this.actionid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof AIOperation) {
            AIOperation _o_ = (AIOperation)_o1_;
            if (this.actionseq != _o_.actionseq) {
                return false;
            } else if (this.actionmoment != _o_.actionmoment) {
                return false;
            } else if (this.actionfighterid != _o_.actionfighterid) {
                return false;
            } else {
                return this.actionid == _o_.actionid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.actionseq;
        _h_ += this.actionmoment;
        _h_ += this.actionfighterid;
        _h_ += this.actionid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.actionseq).append(",");
        _sb_.append(this.actionmoment).append(",");
        _sb_.append(this.actionfighterid).append(",");
        _sb_.append(this.actionid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(AIOperation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.actionseq - _o_.actionseq;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.actionmoment - _o_.actionmoment;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.actionfighterid - _o_.actionfighterid;
                    if (_c_ != 0) {
                        return _c_;
                    } else {
                        _c_ = this.actionid - _o_.actionid;
                        return _c_ != 0 ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
