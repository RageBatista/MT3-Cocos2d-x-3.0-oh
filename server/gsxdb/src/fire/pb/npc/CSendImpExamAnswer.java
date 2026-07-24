//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.impexam.PSendImpExamAnswer;
import gnet.link.Onlines;

public class CSendImpExamAnswer extends __CSendImpExamAnswer__ {
    public static final int PROTOCOL_TYPE = 795464;
    public byte impexamtype;
    public int answerid;
    public byte assisttype;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new PSendImpExamAnswer(roleid, this.answerid, this.impexamtype, this.assisttype)).submit();
        }

    }

    public int getType() {
        return 795464;
    }

    public CSendImpExamAnswer() {
    }

    public CSendImpExamAnswer(byte _impexamtype_, int _answerid_, byte _assisttype_) {
        this.impexamtype = _impexamtype_;
        this.answerid = _answerid_;
        this.assisttype = _assisttype_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamtype);
            _os_.marshal(this.answerid);
            _os_.marshal(this.assisttype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamtype = _os_.unmarshal_byte();
        this.answerid = _os_.unmarshal_int();
        this.assisttype = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSendImpExamAnswer) {
            CSendImpExamAnswer _o_ = (CSendImpExamAnswer)_o1_;
            if (this.impexamtype != _o_.impexamtype) {
                return false;
            } else if (this.answerid != _o_.answerid) {
                return false;
            } else {
                return this.assisttype == _o_.assisttype;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamtype;
        _h_ += this.answerid;
        _h_ += this.assisttype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamtype).append(",");
        _sb_.append(this.answerid).append(",");
        _sb_.append(this.assisttype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CSendImpExamAnswer _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.impexamtype - _o_.impexamtype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.answerid - _o_.answerid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.assisttype - _o_.assisttype;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
