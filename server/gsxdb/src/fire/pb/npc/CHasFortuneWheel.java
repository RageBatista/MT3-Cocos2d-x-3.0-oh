//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class CHasFortuneWheel extends __CHasFortuneWheel__ {
    public static final int PROTOCOL_TYPE = 795495;
    public long npckey;

    protected void process() {
    }

    public int getType() {
        return 795495;
    }

    public CHasFortuneWheel() {
    }

    public CHasFortuneWheel(long _npckey_) {
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return true;
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
        } else if (_o1_ instanceof CHasFortuneWheel) {
            CHasFortuneWheel _o_ = (CHasFortuneWheel)_o1_;
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

    public int compareTo(CHasFortuneWheel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
