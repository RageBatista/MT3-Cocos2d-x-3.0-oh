//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class TeamInfoBasicWithMembers implements Marshal {
    public TeamInfoBasic teaminfobasic;
    public LinkedList<TeamMemberSimple> memberlist;
    public int status;

    public TeamInfoBasicWithMembers() {
        this.teaminfobasic = new TeamInfoBasic();
        this.memberlist = new LinkedList();
    }

    public TeamInfoBasicWithMembers(TeamInfoBasic _teaminfobasic_, LinkedList<TeamMemberSimple> _memberlist_, int _status_) {
        this.teaminfobasic = _teaminfobasic_;
        this.memberlist = _memberlist_;
        this.status = _status_;
    }

    public final boolean _validator_() {
        if (!this.teaminfobasic._validator_()) {
            return false;
        } else {
            for(TeamMemberSimple _v_ : this.memberlist) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.teaminfobasic);
        _os_.compact_uint32(this.memberlist.size());

        for(TeamMemberSimple _v_ : this.memberlist) {
            _os_.marshal(_v_);
        }

        _os_.marshal(this.status);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teaminfobasic.unmarshal(_os_);

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            TeamMemberSimple _v_ = new TeamMemberSimple();
            _v_.unmarshal(_os_);
            this.memberlist.add(_v_);
        }

        this.status = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TeamInfoBasicWithMembers) {
            TeamInfoBasicWithMembers _o_ = (TeamInfoBasicWithMembers)_o1_;
            if (!this.teaminfobasic.equals(_o_.teaminfobasic)) {
                return false;
            } else if (!this.memberlist.equals(_o_.memberlist)) {
                return false;
            } else {
                return this.status == _o_.status;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.teaminfobasic.hashCode();
        _h_ += this.memberlist.hashCode();
        _h_ += this.status;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teaminfobasic).append(",");
        _sb_.append(this.memberlist).append(",");
        _sb_.append(this.status).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
