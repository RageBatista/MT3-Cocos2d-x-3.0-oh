//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;

public class CAbsentReturnTeam extends __CAbsentReturnTeam__ {
    private Team team;
    public static final int PROTOCOL_TYPE = 794441;
    public byte absent;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        long memberRoleId = Onlines.getInstance().findRoleid(this);
        if (memberRoleId >= 0L) {
            if (checkPvP(memberRoleId, this.absent) == 0) {
                PAbsentReturnTeam absentReturnTeamP = new PAbsentReturnTeam(memberRoleId, this.absent);
                if (this.absent == 1) {
                    absentReturnTeamP.submit();
                } else {
                    Long teamId = Roleid2teamid.select(memberRoleId);
                    if (teamId == null) {
                        return;
                    }

                    this.team = new Team(teamId, true);
                    if (!this.team.isInTeam(memberRoleId)) {
                        return;
                    }

                    long leaderRoleId = this.team.getTeamInfo().getTeamleaderid();
                    PropRole prole = new PropRole(leaderRoleId, true);
                    if (prole.getProperties().getCruise() > 0) {
                        TeamManager.logger.debug("队伍（队长）的巡游状态,此时不能归队,teamId: " + teamId);
                        MessageMgr.sendMsgNotify(memberRoleId, 160435, (List)null);
                        return;
                    }

                    PropRole pmemrole = new PropRole(memberRoleId, true);
                    if (pmemrole.getProperties().getCruise() > 0) {
                        TeamManager.logger.debug("队伍（队员）的巡游状态,此时不能归队,teamId: " + teamId);
                        MessageMgr.sendMsgNotify(memberRoleId, 160436, (List)null);
                        return;
                    }

                    Long leaderclanfightid = Roleid2clanfightid.select(leaderRoleId);
                    if (leaderclanfightid != null) {
                        Long memberclanfightid = Roleid2clanfightid.select(memberRoleId);
                        if (!leaderclanfightid.equals(memberclanfightid)) {
                            MessageMgr.sendMsgNotify(memberRoleId, 410020, (List)null);
                            MessageMgr.sendMsgNotify(leaderRoleId, 410021, (List)null);
                            return;
                        }
                    }

                    Role memberRole = RoleManager.getInstance().getRoleByID(memberRoleId);
                    Role leaderRole = RoleManager.getInstance().getRoleByID(leaderRoleId);
                    if (memberRole == null || leaderRole == null) {
                        TeamManager.logger.error("can't get role scene when return team");
                        return;
                    }

                    if (memberRole.getScene() == leaderRole.getScene()) {
                        PGotoTeamLeader go = new PGotoTeamLeader(this.team, memberRoleId, 1);
                        go.submit();
                    } else {
                        PGotoTeamLeader go = new PGotoTeamLeader(this.team, memberRoleId, 2);
                        go.submit();
                    }
                }

            }
        }
    }

    private static int checkPvP(long roleId, byte absent) {
        return PvPTeamHandle.onAbsentReturn(roleId, absent);
    }

    public int getType() {
        return 794441;
    }

    public CAbsentReturnTeam() {
    }

    public CAbsentReturnTeam(byte _absent_) {
        this.absent = _absent_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.absent);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.absent = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAbsentReturnTeam) {
            CAbsentReturnTeam _o_ = (CAbsentReturnTeam)_o1_;
            return this.absent == _o_.absent;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.absent;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.absent).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAbsentReturnTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.absent - _o_.absent;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
