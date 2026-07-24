//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TeamInfoBasic implements Marshal {
    public long teamid;
    public long leaderid;
    public int minlevel;
    public int maxlevel;
    public String leadername;
    public int leaderlevel;
    public int leaderschool;
    public int membernum;
    public int membermaxnum;
    public int targetid;

    public TeamInfoBasic() {
        this.leadername = "";
    }

    public TeamInfoBasic(long _teamid_, long _leaderid_, int _minlevel_, int _maxlevel_, String _leadername_, int _leaderlevel_, int _leaderschool_, int _membernum_, int _membermaxnum_, int _targetid_) {
        this.teamid = _teamid_;
        this.leaderid = _leaderid_;
        this.minlevel = _minlevel_;
        this.maxlevel = _maxlevel_;
        this.leadername = _leadername_;
        this.leaderlevel = _leaderlevel_;
        this.leaderschool = _leaderschool_;
        this.membernum = _membernum_;
        this.membermaxnum = _membermaxnum_;
        this.targetid = _targetid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.teamid);
        _os_.marshal(this.leaderid);
        _os_.marshal(this.minlevel);
        _os_.marshal(this.maxlevel);
        _os_.marshal(this.leadername, "UTF-16LE");
        _os_.marshal(this.leaderlevel);
        _os_.marshal(this.leaderschool);
        _os_.marshal(this.membernum);
        _os_.marshal(this.membermaxnum);
        _os_.marshal(this.targetid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        this.leaderid = _os_.unmarshal_long();
        this.minlevel = _os_.unmarshal_int();
        this.maxlevel = _os_.unmarshal_int();
        this.leadername = _os_.unmarshal_String("UTF-16LE");
        this.leaderlevel = _os_.unmarshal_int();
        this.leaderschool = _os_.unmarshal_int();
        this.membernum = _os_.unmarshal_int();
        this.membermaxnum = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TeamInfoBasic) {
            TeamInfoBasic _o_ = (TeamInfoBasic)_o1_;
            if (this.teamid != _o_.teamid) {
                return false;
            } else if (this.leaderid != _o_.leaderid) {
                return false;
            } else if (this.minlevel != _o_.minlevel) {
                return false;
            } else if (this.maxlevel != _o_.maxlevel) {
                return false;
            } else if (!this.leadername.equals(_o_.leadername)) {
                return false;
            } else if (this.leaderlevel != _o_.leaderlevel) {
                return false;
            } else if (this.leaderschool != _o_.leaderschool) {
                return false;
            } else if (this.membernum != _o_.membernum) {
                return false;
            } else if (this.membermaxnum != _o_.membermaxnum) {
                return false;
            } else {
                return this.targetid == _o_.targetid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.teamid;
        _h_ += (int)this.leaderid;
        _h_ += this.minlevel;
        _h_ += this.maxlevel;
        _h_ += this.leadername.hashCode();
        _h_ += this.leaderlevel;
        _h_ += this.leaderschool;
        _h_ += this.membernum;
        _h_ += this.membermaxnum;
        _h_ += this.targetid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(this.leaderid).append(",");
        _sb_.append(this.minlevel).append(",");
        _sb_.append(this.maxlevel).append(",");
        _sb_.append("T").append(this.leadername.length()).append(",");
        _sb_.append(this.leaderlevel).append(",");
        _sb_.append(this.leaderschool).append(",");
        _sb_.append(this.membernum).append(",");
        _sb_.append(this.membermaxnum).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
