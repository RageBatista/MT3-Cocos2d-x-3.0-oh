//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SImpExamHelp extends __SImpExamHelp__ {
    public static final int PROTOCOL_TYPE = 795468;
    public byte helpcnt;

    protected void process() {
    }

    public int getType() {
        return 795468;
    }

    public SImpExamHelp() {
    }

    public SImpExamHelp(byte _helpcnt_) {
        this.helpcnt = _helpcnt_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.helpcnt);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.helpcnt = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SImpExamHelp) {
            SImpExamHelp _o_ = (SImpExamHelp)_o1_;
            return this.helpcnt == _o_.helpcnt;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.helpcnt;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.helpcnt).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SImpExamHelp _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.helpcnt - _o_.helpcnt;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
