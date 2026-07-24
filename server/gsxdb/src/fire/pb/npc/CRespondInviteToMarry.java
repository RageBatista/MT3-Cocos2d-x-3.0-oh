//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.scene.manager.RoleManager;
import fire.pb.scene.movable.Role;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;

public class CRespondInviteToMarry extends __CRespondInviteToMarry__ {
    public static final int PROTOCOL_TYPE = 817975;
    public byte agree;

    protected void process() {
        Role role = RoleManager.getInstance().getRoleByProtocol(this);
        if (role != null) {
            long roleid = Onlines.getInstance().findRoleid(this);
            if (roleid >= 0L) {
                if (this.agree == 0) {
                    long capitanRoleID = role.getTeam().getCapitanRoleID();
                    MessageMgr.sendMsgNotify(capitanRoleID, 191260, (List)null);
                }

                if (this.agree == 1) {
                    PRespondInviteToMarry pRespondInviteToMarry = new PRespondInviteToMarry(roleid, role);
                    pRespondInviteToMarry.submit();
                }

            }
        }
    }

    public int getType() {
        return 817975;
    }

    public CRespondInviteToMarry() {
    }

    public CRespondInviteToMarry(byte _agree_) {
        this.agree = _agree_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.agree);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.agree = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRespondInviteToMarry) {
            CRespondInviteToMarry _o_ = (CRespondInviteToMarry)_o1_;
            return this.agree == _o_.agree;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.agree;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.agree).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRespondInviteToMarry _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.agree - _o_.agree;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
