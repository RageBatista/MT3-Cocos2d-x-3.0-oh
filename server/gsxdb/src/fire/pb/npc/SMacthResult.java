//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SMacthResult extends __SMacthResult__ {
    public static final int PROTOCOL_TYPE = 795671;
    public long npckey;
    public int result;

    protected void process() {
    }

    public int getType() {
        return 795671;
    }

    public SMacthResult() {
    }

    public SMacthResult(long _npckey_, int _result_) {
        this.npckey = _npckey_;
        this.result = _result_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.result);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.result = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SMacthResult) {
            SMacthResult _o_ = (SMacthResult)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else {
                return this.result == _o_.result;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.result;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.result).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SMacthResult _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.result - _o_.result;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
