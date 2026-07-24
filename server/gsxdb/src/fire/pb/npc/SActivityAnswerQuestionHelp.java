//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SActivityAnswerQuestionHelp extends __SActivityAnswerQuestionHelp__ {
    public static final int PROTOCOL_TYPE = 795535;
    public int helpnum;

    protected void process() {
    }

    public int getType() {
        return 795535;
    }

    public SActivityAnswerQuestionHelp() {
    }

    public SActivityAnswerQuestionHelp(int _helpnum_) {
        this.helpnum = _helpnum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.helpnum);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.helpnum = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SActivityAnswerQuestionHelp) {
            SActivityAnswerQuestionHelp _o_ = (SActivityAnswerQuestionHelp)_o1_;
            return this.helpnum == _o_.helpnum;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.helpnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.helpnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SActivityAnswerQuestionHelp _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.helpnum - _o_.helpnum;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
