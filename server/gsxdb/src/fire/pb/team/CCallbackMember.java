//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.LinkedList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xtable.Locks;
import xtable.Roleid2battleid;
import xtable.Roleid2teamid;

public class CCallbackMember extends __CCallbackMember__ {
    Team team;
    public static final int PROTOCOL_TYPE = 794443;
    public long memberid;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long leaderRoleId = Onlines.getInstance().findRoleid(this);
        if (leaderRoleId >= 0L) {
            Procedure callbackMemberP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(leaderRoleId);
                    if (teamId != null) {
                        CCallbackMember.this.team = new Team(teamId, false);
                        if (!CCallbackMember.this.team.isTeamLeader(leaderRoleId)) {
                            return true;
                        } else {
                            this.lock(Lockeys.get(Locks.ROLELOCK, CCallbackMember.this.team.getAllMemberIds()));
                            if (!CCallbackMember.this.checkTeamStatusValid(leaderRoleId)) {
                                TeamManager.logger.debug("队伍（队长）的状态此时不能召回暂离队员,teamId: " + teamId);
                                return true;
                            } else {
                                PropRole leaderprole = new PropRole(leaderRoleId, true);
                                if (leaderprole.getProperties().getCruise() > 0) {
                                    TeamManager.logger.debug("队伍（队长）的巡游状态,此时不能召回暂离队员,teamId: " + teamId);
                                    MessageMgr.sendMsgNotify(leaderRoleId, 160434, (List)null);
                                    return true;
                                } else {
                                    PropRole callbackprole = new PropRole(CCallbackMember.this.memberid, true);
                                    if (callbackprole.getProperties().getCruise() > 0) {
                                        TeamManager.logger.debug("召回队员的巡游状态,此时不能召回暂离队员,teamId: " + teamId);
                                        MessageMgr.sendMsgNotify(leaderRoleId, 160434, (List)null);
                                        return true;
                                    } else {
                                        Long battleid = Roleid2battleid.select(CCallbackMember.this.memberid);
                                        if (battleid != null) {
                                            MessageMgr.sendMsgNotify(leaderRoleId, 162134, (List)null);
                                            return true;
                                        } else {
                                            List<Long> absentList = new LinkedList();
                                            absentList.addAll(CCallbackMember.this.team.getAbsentMemberIds());
                                            List<Long> callbacklist = new LinkedList();

                                            for(long roleId : absentList) {
                                                BuffAgent buffagent = new BuffRoleImpl(roleId);
                                                if (roleId == CCallbackMember.this.memberid && buffagent.canAddBuff(507009)) {
                                                    callbacklist.add(roleId);
                                                }
                                            }

                                            if (callbacklist.size() == 0) {
                                                MessageMgr.psendMsgNotify(leaderRoleId, 150117, (List)null);
                                                TeamManager.logger.debug("队员不能被召回可能在战斗,teamId: " + teamId);
                                                return true;
                                            } else {
                                                SAskforCallBack sAskforCallBack = new SAskforCallBack();
                                                sAskforCallBack.leaderid = leaderRoleId;
                                                psendWhileCommit(callbacklist, sAskforCallBack);
                                                MessageMgr.sendMsgNotify(leaderRoleId, 140880, (List)null);
                                                return true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        return true;
                    }
                }
            };
            callbackMemberP.submit();
        }
    }

    private boolean checkTeamStatusValid(long leaderRoleId) {
        BuffAgent agent = new BuffRoleImpl(leaderRoleId);
        return agent.canAddBuff(516006);
    }

    public int getType() {
        return 794443;
    }

    public CCallbackMember() {
    }

    public CCallbackMember(long _memberid_) {
        this.memberid = _memberid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.memberid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.memberid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CCallbackMember) {
            CCallbackMember _o_ = (CCallbackMember)_o1_;
            return this.memberid == _o_.memberid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.memberid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.memberid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CCallbackMember _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.memberid - _o_.memberid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
