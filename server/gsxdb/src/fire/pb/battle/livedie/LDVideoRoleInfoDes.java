//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle.livedie;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class LDVideoRoleInfoDes implements Marshal {
    public LDRoleInfoDes role1;
    public LDRoleInfoDes role2;
    public ArrayList<LDTeamRoleInfoDes> teamlist1;
    public ArrayList<LDTeamRoleInfoDes> teamlist2;
    public int battleresult;
    public int rosenum;
    public int roseflag;
    public String videoid;

    public LDVideoRoleInfoDes() {
        this.role1 = new LDRoleInfoDes();
        this.role2 = new LDRoleInfoDes();
        this.teamlist1 = new ArrayList<>();
        this.teamlist2 = new ArrayList<>();
        this.videoid = "";
    }

    public LDVideoRoleInfoDes(LDRoleInfoDes _role1_, LDRoleInfoDes _role2_, ArrayList<LDTeamRoleInfoDes> _teamlist1_, ArrayList<LDTeamRoleInfoDes> _teamlist2_, int _battleresult_, int _rosenum_, int _roseflag_, String _videoid_) {
        this.role1 = _role1_;
        this.role2 = _role2_;
        this.teamlist1 = _teamlist1_;
        this.teamlist2 = _teamlist2_;
        this.battleresult = _battleresult_;
        this.rosenum = _rosenum_;
        this.roseflag = _roseflag_;
        this.videoid = _videoid_;
    }

    public final boolean _validator_() {
        if (!this.role1._validator_()) {
            return false;
        } else if (!this.role2._validator_()) {
            return false;
        } else {
            for(LDTeamRoleInfoDes _v_ : this.teamlist1) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            for(LDTeamRoleInfoDes _v_ : this.teamlist2) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.role1);
        _os_.marshal(this.role2);
        _os_.compact_uint32(this.teamlist1.size());

        for(LDTeamRoleInfoDes _v_ : this.teamlist1) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.teamlist2.size());

        for(LDTeamRoleInfoDes _v_ : this.teamlist2) {
            _os_.marshal(_v_);
        }

        _os_.marshal(this.battleresult);
        _os_.marshal(this.rosenum);
        _os_.marshal(this.roseflag);
        _os_.marshal(this.videoid, "UTF-16LE");
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.role1.unmarshal(_os_);
        this.role2.unmarshal(_os_);

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            LDTeamRoleInfoDes _v_ = new LDTeamRoleInfoDes();
            _v_.unmarshal(_os_);
            this.teamlist1.add(_v_);
        }

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            LDTeamRoleInfoDes _v_ = new LDTeamRoleInfoDes();
            _v_.unmarshal(_os_);
            this.teamlist2.add(_v_);
        }

        this.battleresult = _os_.unmarshal_int();
        this.rosenum = _os_.unmarshal_int();
        this.roseflag = _os_.unmarshal_int();
        this.videoid = _os_.unmarshal_String("UTF-16LE");
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LDVideoRoleInfoDes) {
            LDVideoRoleInfoDes _o_ = (LDVideoRoleInfoDes)_o1_;
            if (!this.role1.equals(_o_.role1)) {
                return false;
            } else if (!this.role2.equals(_o_.role2)) {
                return false;
            } else if (!this.teamlist1.equals(_o_.teamlist1)) {
                return false;
            } else if (!this.teamlist2.equals(_o_.teamlist2)) {
                return false;
            } else if (this.battleresult != _o_.battleresult) {
                return false;
            } else if (this.rosenum != _o_.rosenum) {
                return false;
            } else if (this.roseflag != _o_.roseflag) {
                return false;
            } else {
                return this.videoid.equals(_o_.videoid);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.role1.hashCode();
        _h_ += this.role2.hashCode();
        _h_ += this.teamlist1.hashCode();
        _h_ += this.teamlist2.hashCode();
        _h_ += this.battleresult;
        _h_ += this.rosenum;
        _h_ += this.roseflag;
        _h_ += this.videoid.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.role1).append(",");
        _sb_.append(this.role2).append(",");
        _sb_.append(this.teamlist1).append(",");
        _sb_.append(this.teamlist2).append(",");
        _sb_.append(this.battleresult).append(",");
        _sb_.append(this.rosenum).append(",");
        _sb_.append(this.roseflag).append(",");
        _sb_.append("T").append(this.videoid.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
