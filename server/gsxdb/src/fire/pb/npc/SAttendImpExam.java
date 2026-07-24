//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SAttendImpExam extends __SAttendImpExam__ {
    public static final int PROTOCOL_TYPE = 795458;
    public int impexamtype;

    protected void process() {
    }

    public int getType() {
        return 795458;
    }

    public SAttendImpExam() {
    }

    public SAttendImpExam(int _impexamtype_) {
        this.impexamtype = _impexamtype_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamtype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamtype = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SAttendImpExam) {
            SAttendImpExam _o_ = (SAttendImpExam)_o1_;
            return this.impexamtype == _o_.impexamtype;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamtype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamtype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SAttendImpExam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.impexamtype - _o_.impexamtype;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
