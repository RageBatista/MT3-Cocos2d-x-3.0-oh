//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CBenefitCodeExchange extends __CBenefitCodeExchange__ {
    public static final int PROTOCOL_TYPE = 817973;
    public String code;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId != -1L) {
            PBenefitCodeExchange pBenefitCodeExchange = new PBenefitCodeExchange(roleId, this.code);
            pBenefitCodeExchange.submit();
        }
    }

    public int getType() {
        return 817973;
    }

    public CBenefitCodeExchange() {
        this.code = "";
    }

    public CBenefitCodeExchange(String _name_) {
        this.code = _name_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream octetsStream) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            octetsStream.marshal(this.code, "UTF-16LE");
            return octetsStream;
        }
    }

    public OctetsStream unmarshal(OctetsStream octetsStream) throws MarshalException {
        this.code = octetsStream.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return octetsStream;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CBenefitCodeExchange) {
            CBenefitCodeExchange _o_ = (CBenefitCodeExchange)_o1_;
            return this.code.equals(_o_.code);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.code.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.code.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
