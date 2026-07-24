//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRequestJoinSucc extends __SRequestJoinSucc__ {
    public static final int PROTOCOL_TYPE = 794469;
    public String rolename;

    protected void process() {
    }

    public int getType() {
        return 794469;
    }

    public SRequestJoinSucc() {
        this.rolename = "";
    }

    public SRequestJoinSucc(String _rolename_) {
        this.rolename = _rolename_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.rolename, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRequestJoinSucc) {
            SRequestJoinSucc _o_ = (SRequestJoinSucc)_o1_;
            return this.rolename.equals(_o_.rolename);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rolename.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
