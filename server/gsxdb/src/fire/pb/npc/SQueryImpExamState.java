//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SQueryImpExamState extends __SQueryImpExamState__ {
    public static final int PROTOCOL_TYPE = 795470;
    public byte isattend;

    protected void process() {
    }

    public int getType() {
        return 795470;
    }

    public SQueryImpExamState() {
    }

    public SQueryImpExamState(byte _isattend_) {
        this.isattend = _isattend_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.isattend);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.isattend = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SQueryImpExamState) {
            SQueryImpExamState _o_ = (SQueryImpExamState)_o1_;
            return this.isattend == _o_.isattend;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.isattend;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.isattend).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SQueryImpExamState _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.isattend - _o_.isattend;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
