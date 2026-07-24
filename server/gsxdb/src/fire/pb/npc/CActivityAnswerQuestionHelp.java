//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.clan.ClanUtils;
import fire.pb.mission.activelist.RoleLiveness;
import fire.pb.talk.MessageMgr;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.Calendar;
import java.util.List;
import mkdb.Procedure;
import xbean.ActivityQuestion;
import xbean.ClanInfo;
import xtable.Roleid2activityquestion;

public class CActivityAnswerQuestionHelp extends __CActivityAnswerQuestionHelp__ {
    public static final int PROTOCOL_TYPE = 795532;
    public int questionid;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure activityanswerquestionhelp = new Procedure() {
                protected boolean process() {
                    ClanInfo factionInfo = ClanUtils.getClanInfoById(roleid, true);
                    if (null == factionInfo) {
                        MessageMgr.sendMsgNotify(roleid, 160420, (List)null);
                        return true;
                    } else {
                        RoleLiveness actrole = RoleLiveness.getRoleLiveness(roleid, false);
                        if (actrole != null) {
                            ActivityQuestion activityquestion = Roleid2activityquestion.get(roleid);
                            long now = Calendar.getInstance().getTimeInMillis();
                            if (activityquestion == null) {
                                return true;
                            }

                            long lasttime = activityquestion.getActivityquestionstarttime();
                            if (!DateValidate.inTheSameDay(lasttime, now)) {
                                return true;
                            }

                            if (activityquestion.getHelptimes() < 3) {
                                activityquestion.setHelptimes(activityquestion.getHelptimes() + 1);
                                Procedure.pexecuteWhileCommit(new PSendActivityAnswerQuestionHelp(roleid, CActivityAnswerQuestionHelp.this.questionid));
                                SActivityAnswerQuestionHelp msg = new SActivityAnswerQuestionHelp();
                                msg.helpnum = activityquestion.getHelptimes();
                                Procedure.psendWhileCommit(roleid, msg);
                            } else {
                                MessageMgr.sendMsgNotify(roleid, 160421, (List)null);
                            }
                        }

                        return true;
                    }
                }
            };
            activityanswerquestionhelp.submit();
        }
    }

    public int getType() {
        return 795532;
    }

    public CActivityAnswerQuestionHelp() {
    }

    public CActivityAnswerQuestionHelp(int _questionid_) {
        this.questionid = _questionid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questionid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questionid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CActivityAnswerQuestionHelp) {
            CActivityAnswerQuestionHelp _o_ = (CActivityAnswerQuestionHelp)_o1_;
            return this.questionid == _o_.questionid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questionid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questionid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CActivityAnswerQuestionHelp _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.questionid - _o_.questionid;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
