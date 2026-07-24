//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSendImpExamVill extends __SSendImpExamVill__ {
    public static final int PROTOCOL_TYPE = 795461;
    public ImpExamBean impexamdata;
    public int historyright;
    public byte isover;

    protected void process() {
    }

    public int getType() {
        return 795461;
    }

    public SSendImpExamVill() {
        this.impexamdata = new ImpExamBean();
    }

    public SSendImpExamVill(ImpExamBean _impexamdata_, int _historyright_, byte _isover_) {
        this.impexamdata = _impexamdata_;
        this.historyright = _historyright_;
        this.isover = _isover_;
    }

    public final boolean _validator_() {
        return this.impexamdata._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamdata);
            _os_.marshal(this.historyright);
            _os_.marshal(this.isover);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamdata.unmarshal(_os_);
        this.historyright = _os_.unmarshal_int();
        this.isover = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendImpExamVill) {
            SSendImpExamVill _o_ = (SSendImpExamVill)_o1_;
            if (!this.impexamdata.equals(_o_.impexamdata)) {
                return false;
            } else if (this.historyright != _o_.historyright) {
                return false;
            } else {
                return this.isover == _o_.isover;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamdata.hashCode();
        _h_ += this.historyright;
        _h_ += this.isover;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamdata).append(",");
        _sb_.append(this.historyright).append(",");
        _sb_.append(this.isover).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSendImpExamVill _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.impexamdata.compareTo(_o_.impexamdata);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.historyright - _o_.historyright;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.isover - _o_.isover;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
