//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Operation implements Marshal, Comparable<Operation> {
    public int operationtype;
    public int aim;
    public int operationid;

    public Operation() {
    }

    public Operation(int _operationtype_, int _aim_, int _operationid_) {
        this.operationtype = _operationtype_;
        this.aim = _aim_;
        this.operationid = _operationid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.operationtype);
        _os_.marshal(this.aim);
        _os_.marshal(this.operationid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.operationtype = _os_.unmarshal_int();
        this.aim = _os_.unmarshal_int();
        this.operationid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Operation) {
            Operation _o_ = (Operation)_o1_;
            if (this.operationtype != _o_.operationtype) {
                return false;
            } else if (this.aim != _o_.aim) {
                return false;
            } else {
                return this.operationid == _o_.operationid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.operationtype;
        _h_ += this.aim;
        _h_ += this.operationid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.operationtype).append(",");
        _sb_.append(this.aim).append(",");
        _sb_.append(this.operationid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Operation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.operationtype - _o_.operationtype;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.aim - _o_.aim;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.operationid - _o_.operationid;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}
