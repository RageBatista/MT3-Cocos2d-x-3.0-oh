//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.clan.ClanUtils;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import xbean.ClanInfo;
import xbean.ClanMemberInfo;
import xtable.Roleid2clanfightid;

public class CAcceptToTeam extends __CAcceptToTeam__ {
    public static final int PROTOCOL_TYPE = 787235;
    public long roleid;
    public int accept;

    protected void process() {
        TeamManager.logger.info("Enter: " + this.getClass());
        long leaderRoleId = Onlines.getInstance().findRoleid(this);
        long applierRoleId = this.roleid;
        if (leaderRoleId >= 0L) {
            if (applierRoleId != 0L) {
                PropRole applierprop = new PropRole(applierRoleId, true);
                if (applierprop.getProperties().getCruise() > 0) {
                    TeamManager.logger.info("CAcceptToTeam:申请入队者" + applierRoleId + "在巡游状态,此时不能申请入队");
                    MessageMgr.sendMsgNotify(applierRoleId, 162027, (List)null);
                    MessageMgr.sendMsgNotify(leaderRoleId, 162026, (List)null);
                    return;
                }

                PropRole leaderprop = new PropRole(this.roleid, true);
                if (leaderprop.getProperties().getCruise() > 0) {
                    TeamManager.logger.info("CAcceptToTeam:队伍队长" + this.roleid + "申请人" + applierRoleId + "队伍队长正在巡游状态,不能申请入队");
                    MessageMgr.sendMsgNotify(applierRoleId, 162026, (List)null);
                    MessageMgr.sendMsgNotify(leaderRoleId, 162027, (List)null);
                    return;
                }
            }

            Long leaderclanfightid = Roleid2clanfightid.select(leaderRoleId);
            if (leaderclanfightid != null) {
                Long applierclanfightid = Roleid2clanfightid.select(applierRoleId);
                if (!leaderclanfightid.equals(applierclanfightid)) {
                    MessageMgr.sendMsgNotify(leaderRoleId, 410028, (List)null);
                    return;
                }

                ClanInfo claninfo = ClanUtils.getClanInfoById(this.roleid, true);
                if (claninfo == null) {
                    return;
                }

                ClanMemberInfo memberinfo = (ClanMemberInfo)claninfo.getMembers().get(applierRoleId);
                if (memberinfo == null) {
                    MessageMgr.sendMsgNotify(leaderRoleId, 410029, (List)null);
                    return;
                }
            } else {
                Long applierclanfightid = Roleid2clanfightid.select(applierRoleId);
                if (applierclanfightid != null && !applierclanfightid.equals(leaderclanfightid)) {
                    MessageMgr.sendMsgNotify(applierclanfightid, 410030, (List)null);
                    return;
                }
            }

            (new PAcceptToTeam(leaderRoleId, applierRoleId, this.accept, true)).submit();
        }
    }

    public int getType() {
        return 787235;
    }

    public CAcceptToTeam() {
    }

    public CAcceptToTeam(long _roleid_, int _accept_) {
        this.roleid = _roleid_;
        this.accept = _accept_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.accept);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.accept = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAcceptToTeam) {
            CAcceptToTeam _o_ = (CAcceptToTeam)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.accept == _o_.accept;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.accept;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.accept).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAcceptToTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.accept - _o_.accept;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
