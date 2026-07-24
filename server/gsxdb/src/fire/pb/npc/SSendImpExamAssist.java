//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSendImpExamAssist extends __SSendImpExamAssist__ {
    public static final int PROTOCOL_TYPE = 795466;
    public byte impexamtype;
    public byte assisttype;
    public int answerid;

    protected void process() {
    }

    public int getType() {
        return 795466;
    }

    public SSendImpExamAssist() {
    }

    public SSendImpExamAssist(byte _impexamtype_, byte _assisttype_, int _answerid_) {
        this.impexamtype = _impexamtype_;
        this.assisttype = _assisttype_;
        this.answerid = _answerid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamtype);
            _os_.marshal(this.assisttype);
            _os_.marshal(this.answerid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamtype = _os_.unmarshal_byte();
        this.assisttype = _os_.unmarshal_byte();
        this.answerid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendImpExamAssist) {
            SSendImpExamAssist _o_ = (SSendImpExamAssist)_o1_;
            if (this.impexamtype != _o_.impexamtype) {
                return false;
            } else if (this.assisttype != _o_.assisttype) {
                return false;
            } else {
                return this.answerid == _o_.answerid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamtype;
        _h_ += this.assisttype;
        _h_ += this.answerid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamtype).append(",");
        _sb_.append(this.assisttype).append(",");
        _sb_.append(this.answerid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSendImpExamAssist _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.impexamtype - _o_.impexamtype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.assisttype - _o_.assisttype;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.answerid - _o_.answerid;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
