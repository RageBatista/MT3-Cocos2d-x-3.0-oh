//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRequestMatchInfo extends __SRequestMatchInfo__ {
    public static final int PROTOCOL_TYPE = 794513;
    public int teammatchnum;
    public int playermatchnum;

    protected void process() {
    }

    public int getType() {
        return 794513;
    }

    public SRequestMatchInfo() {
    }

    public SRequestMatchInfo(int _teammatchnum_, int _playermatchnum_) {
        this.teammatchnum = _teammatchnum_;
        this.playermatchnum = _playermatchnum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teammatchnum);
            _os_.marshal(this.playermatchnum);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teammatchnum = _os_.unmarshal_int();
        this.playermatchnum = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRequestMatchInfo) {
            SRequestMatchInfo _o_ = (SRequestMatchInfo)_o1_;
            if (this.teammatchnum != _o_.teammatchnum) {
                return false;
            } else {
                return this.playermatchnum == _o_.playermatchnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.teammatchnum;
        _h_ += this.playermatchnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teammatchnum).append(",");
        _sb_.append(this.playermatchnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRequestMatchInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.teammatchnum - _o_.teammatchnum;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.playermatchnum - _o_.playermatchnum;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
