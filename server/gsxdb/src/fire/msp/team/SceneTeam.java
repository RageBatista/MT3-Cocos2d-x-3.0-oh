//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.Iterator;
import java.util.LinkedList;

public class SceneTeam implements Marshal {
    public long teamid;
    public long leaderid;
    public LinkedList<SceneTeamMember> memebers;

    public SceneTeam() {
        this.memebers = new LinkedList();
    }

    public SceneTeam(long _teamid_, long _leaderid_, LinkedList<SceneTeamMember> _memebers_) {
        this.teamid = _teamid_;
        this.leaderid = _leaderid_;
        this.memebers = _memebers_;
    }

    public final boolean _validator_() {
        Iterator var1 = this.memebers.iterator();

        SceneTeamMember _v_;
        do {
            if (!var1.hasNext()) {
                return true;
            }

            _v_ = (SceneTeamMember)var1.next();
        } while(_v_._validator_());

        return false;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.teamid);
        _os_.marshal(this.leaderid);
        _os_.compact_uint32(this.memebers.size());
        Iterator var2 = this.memebers.iterator();

        while(var2.hasNext()) {
            SceneTeamMember _v_ = (SceneTeamMember)var2.next();
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        this.leaderid = _os_.unmarshal_long();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            SceneTeamMember _v_ = new SceneTeamMember();
            _v_.unmarshal(_os_);
            this.memebers.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SceneTeam) {
            SceneTeam _o_ = (SceneTeam)_o1_;
            if (this.teamid != _o_.teamid) {
                return false;
            } else if (this.leaderid != _o_.leaderid) {
                return false;
            } else {
                return this.memebers.equals(_o_.memebers);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.teamid;
        _h_ += (int)this.leaderid;
        _h_ += this.memebers.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(this.leaderid).append(",");
        _sb_.append(this.memebers).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
