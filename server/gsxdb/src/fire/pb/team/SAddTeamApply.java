//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SAddTeamApply extends __SAddTeamApply__ {
    public static final int PROTOCOL_TYPE = 794437;
    public LinkedList<TeamApplyBasic> applylist;

    protected void process() {
    }

    public int getType() {
        return 794437;
    }

    public SAddTeamApply() {
        this.applylist = new LinkedList();
    }

    public SAddTeamApply(LinkedList<TeamApplyBasic> _applylist_) {
        this.applylist = _applylist_;
    }

    public final boolean _validator_() {
        for(TeamApplyBasic _v_ : this.applylist) {
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
            _os_.compact_uint32(this.applylist.size());

            for(TeamApplyBasic _v_ : this.applylist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            TeamApplyBasic _v_ = new TeamApplyBasic();
            _v_.unmarshal(_os_);
            this.applylist.add(_v_);
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
        } else if (_o1_ instanceof SAddTeamApply) {
            SAddTeamApply _o_ = (SAddTeamApply)_o1_;
            return this.applylist.equals(_o_.applylist);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.applylist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.applylist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
