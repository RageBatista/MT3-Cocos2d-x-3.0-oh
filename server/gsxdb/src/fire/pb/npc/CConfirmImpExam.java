//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.impexam.PConfirmProc;
import gnet.link.Onlines;

public class CConfirmImpExam extends __CConfirmImpExam__ {
    public static final int PROTOCOL_TYPE = 795459;
    public int impexamtype;
    public byte operate;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new PConfirmProc(roleid, this.impexamtype, this.operate)).submit();
        }

    }

    public int getType() {
        return 795459;
    }

    public CConfirmImpExam() {
    }

    public CConfirmImpExam(int _impexamtype_, byte _operate_) {
        this.impexamtype = _impexamtype_;
        this.operate = _operate_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamtype);
            _os_.marshal(this.operate);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamtype = _os_.unmarshal_int();
        this.operate = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CConfirmImpExam) {
            CConfirmImpExam _o_ = (CConfirmImpExam)_o1_;
            if (this.impexamtype != _o_.impexamtype) {
                return false;
            } else {
                return this.operate == _o_.operate;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamtype;
        _h_ += this.operate;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamtype).append(",");
        _sb_.append(this.operate).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CConfirmImpExam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.impexamtype - _o_.impexamtype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.operate - _o_.operate;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
