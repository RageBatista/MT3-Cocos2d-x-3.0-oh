//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.redirect.PExitCopyProc;
import gnet.link.Onlines;

public class CExitCopy extends __CExitCopy__ {
    public static final int PROTOCOL_TYPE = 795668;
    public byte gototype;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new PExitCopyProc(roleid, this.gototype)).submit();
        }

    }

    public int getType() {
        return 795668;
    }

    public CExitCopy() {
    }

    public CExitCopy(byte _gototype_) {
        this.gototype = _gototype_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.gototype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.gototype = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CExitCopy) {
            CExitCopy _o_ = (CExitCopy)_o1_;
            return this.gototype == _o_.gototype;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.gototype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.gototype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CExitCopy _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.gototype - _o_.gototype;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
