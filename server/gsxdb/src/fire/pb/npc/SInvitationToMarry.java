//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SInvitationToMarry extends __SInvitationToMarry__ {
    public static final int PROTOCOL_TYPE = 817974;
    public long leaderroleid;
    public String invitername;
    public int inviterlevel;
    public int op;

    protected void process() {
    }

    public int getType() {
        return 817974;
    }

    public SInvitationToMarry() {
        this.invitername = "";
    }

    public SInvitationToMarry(long _leaderroleid_, String _invitername_, int _inviterlevel_, int _op_) {
        this.leaderroleid = _leaderroleid_;
        this.invitername = _invitername_;
        this.inviterlevel = _inviterlevel_;
        this.op = _op_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.leaderroleid);
            _os_.marshal(this.invitername, "UTF-16LE");
            _os_.marshal(this.inviterlevel);
            _os_.marshal(this.op);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.leaderroleid = _os_.unmarshal_long();
        this.invitername = _os_.unmarshal_String("UTF-16LE");
        this.inviterlevel = _os_.unmarshal_int();
        this.op = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SInvitationToMarry) {
            SInvitationToMarry _o_ = (SInvitationToMarry)_o1_;
            if (this.leaderroleid != _o_.leaderroleid) {
                return false;
            } else if (!this.invitername.equals(_o_.invitername)) {
                return false;
            } else if (this.inviterlevel != _o_.inviterlevel) {
                return false;
            } else {
                return this.op == _o_.op;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.leaderroleid;
        _h_ += this.invitername.hashCode();
        _h_ += this.inviterlevel;
        _h_ += this.op;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.leaderroleid).append(",");
        _sb_.append("T").append(this.invitername.length()).append(",");
        _sb_.append(this.inviterlevel).append(",");
        _sb_.append(this.op).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
