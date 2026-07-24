//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.Properties;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CAnswerforCallBack extends __CAnswerforCallBack__ {
    Team team;
    public static final int PROTOCOL_TYPE = 794457;
    public byte agree;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long memberRoleId = Onlines.getInstance().findRoleid(this);
        if (memberRoleId >= 0L) {
            Procedure answerCallbackP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(memberRoleId);
                    if (teamId != null) {
                        CAnswerforCallBack.this.team = new Team(teamId, false);
                        if (!CAnswerforCallBack.this.team.isInTeam(memberRoleId)) {
                            return true;
                        } else {
                            long leaderRoleId = CAnswerforCallBack.this.team.getTeamInfo().getTeamleaderid();
                            Long[] roleids = new Long[2];
                            if (leaderRoleId < memberRoleId) {
                                roleids[0] = leaderRoleId;
                                roleids[1] = memberRoleId;
                            } else {
                                roleids[0] = memberRoleId;
                                roleids[1] = leaderRoleId;
                            }

                            this.lock(Lockeys.get(Locks.ROLELOCK, (Object[])roleids));
                            if (CAnswerforCallBack.this.agree == 1) {
                                if (CAnswerforCallBack.this.team.getTeamMemberState(memberRoleId) != 2) {
                                    TeamManager.logger.debug("FAIL:队员不处于暂离中 , memberRoleId" + memberRoleId);
                                } else if (!CAnswerforCallBack.this.checkMemberReturnStatusValid(memberRoleId)) {
                                    TeamManager.logger.debug("FAIL:成员处在不可归队的状态 , memberRoleId" + memberRoleId);
                                } else if (CAnswerforCallBack.this.team.isMemberInReturnScale(memberRoleId)) {
                                    if (CAnswerforCallBack.this.checkTeamReturnStatusValid(CAnswerforCallBack.this.team)) {
                                        CAnswerforCallBack.this.team.setTeamMemberStateWithSP(memberRoleId, 1);
                                        TeamManager.logger.debugWhileCommit("SUCC:队伍处在可以归队的状态，改变队员为正常状态 , memberRoleId" + memberRoleId);
                                    } else {
                                        CAnswerforCallBack.this.team.setTeamMemberStateWithSP(memberRoleId, 3);
                                        TeamManager.logger.debugWhileCommit("SUCC:成员回归队伍,进入归队中状态 , memberRoleId" + memberRoleId);
                                    }
                                } else {
                                    psend(memberRoleId, new STeamError(26));
                                    TeamManager.logger.debug("FAIL:在回归范围之外 , memberRoleId" + memberRoleId);
                                }
                            } else {
                                List<String> paras = new ArrayList();
                                Properties newProperty = xtable.Properties.select(memberRoleId);
                                paras.add(newProperty.getRolename());
                                MessageMgr.psendMsgNotify(leaderRoleId, 150116, paras);
                            }

                            return true;
                        }
                    } else {
                        return true;
                    }
                }
            };
            answerCallbackP.submit();
        }
    }

    private boolean checkMemberReturnStatusValid(long memberRoleId) {
        BuffAgent agent = new BuffRoleImpl(memberRoleId);
        if (agent.canAddBuff(507009)) {
            return true;
        } else {
            MessageMgr.sendMsgNotify(memberRoleId, 141618, (List)null);
            return false;
        }
    }

    private boolean checkTeamReturnStatusValid(Team team) {
        return true;
    }

    public int getType() {
        return 794457;
    }

    public CAnswerforCallBack() {
    }

    public CAnswerforCallBack(byte _agree_) {
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
        } else if (_o1_ instanceof CAnswerforCallBack) {
            CAnswerforCallBack _o_ = (CAnswerforCallBack)_o1_;
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

    public int compareTo(CAnswerforCallBack _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.agree - _o_.agree;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
