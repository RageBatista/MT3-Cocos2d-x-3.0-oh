//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.instancezone.PGiveUpAnswerQuestion;
import gnet.link.Onlines;

public class CGiveUpQuestion extends __CGiveUpQuestion__ {
    public static final int PROTOCOL_TYPE = 795523;
    public int questiontype;
    public long npckey;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId != -1L) {
            if (this.questiontype == 7) {
                (new PGiveUpAnswerQuestion(roleId, this.npckey)).submit();
            }
        }
    }

    public int getType() {
        return 795523;
    }

    public CGiveUpQuestion() {
    }

    public CGiveUpQuestion(int _questiontype_, long _npckey_) {
        this.questiontype = _questiontype_;
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questiontype);
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questiontype = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CGiveUpQuestion) {
            CGiveUpQuestion _o_ = (CGiveUpQuestion)_o1_;
            if (this.questiontype != _o_.questiontype) {
                return false;
            } else {
                return this.npckey == _o_.npckey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questiontype;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questiontype).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CGiveUpQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.questiontype - _o_.questiontype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.npckey - _o_.npckey);
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
