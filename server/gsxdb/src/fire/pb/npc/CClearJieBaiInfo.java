//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.scene.manager.RoleManager;
import fire.pb.scene.movable.Role;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.jiebaiAskInfo;
import xtable.Jiebaiinfos;

public class CClearJieBaiInfo extends __CClearJieBaiInfo__ {
    public static final int PROTOCOL_TYPE = 817948;
    public long teamid;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Role role = RoleManager.getInstance().getRoleByProtocol(this);
            if (role != null) {
                if (role.getTeam() != null) {
                    if (roleid == role.getTeam().getCapitanRoleID()) {
                        Procedure clearjiebaiinfo = new Procedure() {
                            protected boolean process() {
                                jiebaiAskInfo select = Jiebaiinfos.select(CClearJieBaiInfo.this.teamid);
                                if (select != null) {
                                    Jiebaiinfos.remove(CClearJieBaiInfo.this.teamid);
                                    return true;
                                } else {
                                    return true;
                                }
                            }
                        };
                        clearjiebaiinfo.submit();
                    }
                }
            }
        }
    }

    public int getType() {
        return 817948;
    }

    public CClearJieBaiInfo() {
    }

    public CClearJieBaiInfo(long _teamid_) {
        this.teamid = _teamid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teamid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CClearJieBaiInfo) {
            CClearJieBaiInfo _o_ = (CClearJieBaiInfo)_o1_;
            return this.teamid == _o_.teamid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.teamid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CClearJieBaiInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = Long.signum(this.teamid - _o_.teamid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
