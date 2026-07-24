//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SPetGossip extends __SPetGossip__ {
    public static final int PROTOCOL_TYPE = 788453;
    public int battleid;
    public int chatindex;

    protected void process() {
    }

    public int getType() {
        return 788453;
    }

    public SPetGossip() {
    }

    public SPetGossip(int _battleid_, int _chatindex_) {
        this.battleid = _battleid_;
        this.chatindex = _chatindex_;
    }

    public final boolean _validator_() {
        if (this.battleid < 1) {
            return false;
        } else {
            return this.chatindex >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.battleid);
            _os_.marshal(this.chatindex);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.battleid = _os_.unmarshal_int();
        this.chatindex = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SPetGossip) {
            SPetGossip _o_ = (SPetGossip)_o1_;
            if (this.battleid != _o_.battleid) {
                return false;
            } else {
                return this.chatindex == _o_.chatindex;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.battleid;
        _h_ += this.chatindex;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.battleid).append(",");
        _sb_.append(this.chatindex).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SPetGossip _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.battleid - _o_.battleid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.chatindex - _o_.chatindex;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
