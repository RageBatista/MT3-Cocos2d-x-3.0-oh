//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SBeginSchoolWheel1 extends __SBeginSchoolWheel1__ {
    public static final int PROTOCOL_TYPE = 800026;
    public int wheelindex;

    protected void process() {
    }

    public int getType() {
        return 800026;
    }

    public SBeginSchoolWheel1() {
    }

    public SBeginSchoolWheel1(int _wheelindex_) {
        this.wheelindex = _wheelindex_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.wheelindex);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.wheelindex = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SBeginSchoolWheel1) {
            SBeginSchoolWheel1 _o_ = (SBeginSchoolWheel1)_o1_;
            return this.wheelindex == _o_.wheelindex;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.wheelindex;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.wheelindex).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SBeginSchoolWheel1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.wheelindex - _o_.wheelindex;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}
