//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.http;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SResponsePost extends __SResponsePost__ {
    public static final int PROTOCOL_TYPE = 800301;
    public String retvalue;
    public int dataid;

    protected void process() {
    }

    public int getType() {
        return 800301;
    }

    public SResponsePost() {
        this.retvalue = "";
    }

    public SResponsePost(String _retvalue_, int _dataid_) {
        this.retvalue = _retvalue_;
        this.dataid = _dataid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.retvalue, "UTF-16LE");
            _os_.marshal(this.dataid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.retvalue = _os_.unmarshal_String("UTF-16LE");
        this.dataid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SResponsePost) {
            SResponsePost _o_ = (SResponsePost)_o1_;
            return this.retvalue.equals(_o_.retvalue) && this.dataid == _o_.dataid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.retvalue.hashCode();
        return _h_ + this.dataid;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.retvalue.length()).append(",");
        _sb_.append(this.dataid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
