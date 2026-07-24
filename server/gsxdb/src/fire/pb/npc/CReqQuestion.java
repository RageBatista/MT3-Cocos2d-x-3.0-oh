//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CReqQuestion extends __CReqQuestion__ {
    public static final int PROTOCOL_TYPE = 795439;
    public long npckey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (this.validate(roleid)) {
            ;
        }
    }

    protected boolean validate(long roleid) {
        return roleid >= 0L;
    }

    public int getType() {
        return 795439;
    }

    public CReqQuestion() {
    }

    public CReqQuestion(long _npckey_) {
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return this.npckey >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
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
        } else if (_o1_ instanceof CReqQuestion) {
            CReqQuestion _o_ = (CReqQuestion)_o1_;
            return this.npckey == _o_.npckey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CReqQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
