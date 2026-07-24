//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SAddTeamMember extends __SAddTeamMember__ {
    public static final int PROTOCOL_TYPE = 794436;
    public LinkedList<TeamMemberBasic> memberlist;

    protected void process() {
    }

    public int getType() {
        return 794436;
    }

    public SAddTeamMember() {
        this.memberlist = new LinkedList();
    }

    public SAddTeamMember(LinkedList<TeamMemberBasic> _memberlist_) {
        this.memberlist = _memberlist_;
    }

    public final boolean _validator_() {
        for(TeamMemberBasic _v_ : this.memberlist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.memberlist.size());

            for(TeamMemberBasic _v_ : this.memberlist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            TeamMemberBasic _v_ = new TeamMemberBasic();
            _v_.unmarshal(_os_);
            this.memberlist.add(_v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SAddTeamMember) {
            SAddTeamMember _o_ = (SAddTeamMember)_o1_;
            return this.memberlist.equals(_o_.memberlist);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.memberlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.memberlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
