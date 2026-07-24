//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SUpdateTeamMemberBasic extends __SUpdateTeamMemberBasic__ {
    public static final int PROTOCOL_TYPE = 794485;
    public TeamMemberBasic data;

    protected void process() {
    }

    public int getType() {
        return 794485;
    }

    public SUpdateTeamMemberBasic() {
        this.data = new TeamMemberBasic();
    }

    public SUpdateTeamMemberBasic(TeamMemberBasic _data_) {
        this.data = _data_;
    }

    public final boolean _validator_() {
        return this.data._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.data);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.data.unmarshal(_os_);
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SUpdateTeamMemberBasic) {
            SUpdateTeamMemberBasic _o_ = (SUpdateTeamMemberBasic)_o1_;
            return this.data.equals(_o_.data);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.data.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.data).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
