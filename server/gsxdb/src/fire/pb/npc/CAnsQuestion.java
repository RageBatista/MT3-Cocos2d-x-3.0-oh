//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CAnsQuestion extends __CAnsQuestion__ {
    public static final int PROTOCOL_TYPE = 795441;
    public long npckey;
    public int questionid;
    public int answer;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            ;
        }
    }

    public int getType() {
        return 795441;
    }

    public CAnsQuestion() {
    }

    public CAnsQuestion(long _npckey_, int _questionid_, int _answer_) {
        this.npckey = _npckey_;
        this.questionid = _questionid_;
        this.answer = _answer_;
    }

    public final boolean _validator_() {
        if (this.npckey < 0L) {
            return false;
        } else if (this.questionid < 0) {
            return false;
        } else {
            return this.answer >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.questionid);
            _os_.marshal(this.answer);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.questionid = _os_.unmarshal_int();
        this.answer = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAnsQuestion) {
            CAnsQuestion _o_ = (CAnsQuestion)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.questionid != _o_.questionid) {
                return false;
            } else {
                return this.answer == _o_.answer;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.questionid;
        _h_ += this.answer;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.questionid).append(",");
        _sb_.append(this.answer).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAnsQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.questionid - _o_.questionid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.answer - _o_.answer;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
