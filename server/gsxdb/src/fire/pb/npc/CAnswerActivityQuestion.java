//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.answerquestion.PAnswerActivityQuestion;
import gnet.link.Onlines;

public class CAnswerActivityQuestion extends __CAnswerActivityQuestion__ {
    public static final int PROTOCOL_TYPE = 795533;
    public int questionid;
    public int answerid;
    public int xiangguanid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PAnswerActivityQuestion(roleId, this.xiangguanid, this.questionid, this.answerid)).submit();
        }
    }

    public int getType() {
        return 795533;
    }

    public CAnswerActivityQuestion() {
    }

    public CAnswerActivityQuestion(int _questionid_, int _answerid_, int _xiangguanid_) {
        this.questionid = _questionid_;
        this.answerid = _answerid_;
        this.xiangguanid = _xiangguanid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questionid);
            _os_.marshal(this.answerid);
            _os_.marshal(this.xiangguanid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questionid = _os_.unmarshal_int();
        this.answerid = _os_.unmarshal_int();
        this.xiangguanid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAnswerActivityQuestion) {
            CAnswerActivityQuestion _o_ = (CAnswerActivityQuestion)_o1_;
            if (this.questionid != _o_.questionid) {
                return false;
            } else if (this.answerid != _o_.answerid) {
                return false;
            } else {
                return this.xiangguanid == _o_.xiangguanid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questionid;
        _h_ += this.answerid;
        _h_ += this.xiangguanid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questionid).append(",");
        _sb_.append(this.answerid).append(",");
        _sb_.append(this.xiangguanid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAnswerActivityQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.questionid - _o_.questionid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.answerid - _o_.answerid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.xiangguanid - _o_.xiangguanid;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
