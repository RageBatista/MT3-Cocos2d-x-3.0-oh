//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SRequestTeamMatchList extends __SRequestTeamMatchList__ {
    public static final int PROTOCOL_TYPE = 794510;
    public int ret;
    public int targetid;
    public LinkedList<TeamInfoBasicWithMembers> teamlist;

    protected void process() {
    }

    public int getType() {
        return 794510;
    }

    public SRequestTeamMatchList() {
        this.teamlist = new LinkedList();
    }

    public SRequestTeamMatchList(int _ret_, int _targetid_, LinkedList<TeamInfoBasicWithMembers> _teamlist_) {
        this.ret = _ret_;
        this.targetid = _targetid_;
        this.teamlist = _teamlist_;
    }

    public final boolean _validator_() {
        for(TeamInfoBasicWithMembers _v_ : this.teamlist) {
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
            _os_.marshal(this.ret);
            _os_.marshal(this.targetid);
            _os_.compact_uint32(this.teamlist.size());

            for(TeamInfoBasicWithMembers _v_ : this.teamlist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.ret = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            TeamInfoBasicWithMembers _v_ = new TeamInfoBasicWithMembers();
            _v_.unmarshal(_os_);
            this.teamlist.add(_v_);
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
        } else if (_o1_ instanceof SRequestTeamMatchList) {
            SRequestTeamMatchList _o_ = (SRequestTeamMatchList)_o1_;
            if (this.ret != _o_.ret) {
                return false;
            } else if (this.targetid != _o_.targetid) {
                return false;
            } else {
                return this.teamlist.equals(_o_.teamlist);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.ret;
        _h_ += this.targetid;
        _h_ += this.teamlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.ret).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.teamlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
