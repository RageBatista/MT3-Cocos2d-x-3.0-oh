//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSwapMember extends __SSwapMember__ {
    public static final int PROTOCOL_TYPE = 794453;
    public int index1;
    public int index2;

    protected void process() {
    }

    public int getType() {
        return 794453;
    }

    public SSwapMember() {
    }

    public SSwapMember(int _index1_, int _index2_) {
        this.index1 = _index1_;
        this.index2 = _index2_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.index1);
            _os_.marshal(this.index2);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.index1 = _os_.unmarshal_int();
        this.index2 = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSwapMember) {
            SSwapMember _o_ = (SSwapMember)_o1_;
            if (this.index1 != _o_.index1) {
                return false;
            } else {
                return this.index2 == _o_.index2;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.index1;
        _h_ += this.index2;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.index1).append(",");
        _sb_.append(this.index2).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSwapMember _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.index1 - _o_.index1;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.index2 - _o_.index2;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
