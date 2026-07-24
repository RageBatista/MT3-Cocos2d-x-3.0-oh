//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SBattleToNpcError extends __SBattleToNpcError__ {
    public static final int PROTOCOL_TYPE = 795453;
    public int battleerror;

    protected void process() {
    }

    public int getType() {
        return 795453;
    }

    public SBattleToNpcError() {
    }

    public SBattleToNpcError(int _battleerror_) {
        this.battleerror = _battleerror_;
    }

    public final boolean _validator_() {
        return this.battleerror < 0;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.battleerror);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.battleerror = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SBattleToNpcError) {
            SBattleToNpcError _o_ = (SBattleToNpcError)_o1_;
            return this.battleerror == _o_.battleerror;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.battleerror;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.battleerror).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SBattleToNpcError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.battleerror - _o_.battleerror;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
