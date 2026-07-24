//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.ActivityConfNew;
import fire.pb.activity.answerquestion.ActivityQuestionManager;
import fire.pb.mission.activelist.RoleLiveness;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.Calendar;
import mkdb.Procedure;
import xbean.ActivityQuestion;
import xbean.Pod;
import xbean.Properties;
import xtable.Roleid2activityquestion;

public class CRequestActivityAnswerQuestion extends __CRequestActivityAnswerQuestion__ {
    public static final int PROTOCOL_TYPE = 795527;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure requestteammatchlist = new Procedure() {
                protected boolean process() {
                    RoleLiveness actrole = RoleLiveness.getRoleLiveness(roleid, false);
                    if (actrole != null) {
                        int count = actrole.getActiveNum(213);
                        ActivityConfNew activity = RoleLiveness.getConfigActivity(213);
                        boolean start = ActivityQuestionManager.getInstance().IsStart();
                        if (count < activity.maxnum && start) {
                            Properties prop = xtable.Properties.select(roleid);
                            if (prop == null) {
                                return false;
                            }

                            if (prop.getLevel() < activity.level) {
                                return false;
                            }

                            ActivityQuestion activityquestion = Roleid2activityquestion.get(roleid);
                            long now = Calendar.getInstance().getTimeInMillis();
                            if (activityquestion == null) {
                                activityquestion = Pod.newActivityQuestion();
                                Roleid2activityquestion.insert(roleid, activityquestion);
                                ActivityQuestionManager.getInstance().ResetActivityQuestionData(activityquestion, now, true);
                            } else {
                                long lasttime = activityquestion.getActivityquestionstarttime();
                                if (!DateValidate.inTheSameDay(lasttime, now)) {
                                    ActivityQuestionManager.getInstance().ResetActivityQuestionData(activityquestion, now, true);
                                }
                            }

                            ActivityQuestionManager.getInstance().sendQuestion(roleid, activityquestion, (byte)0);
                        }
                    }

                    return true;
                }
            };
            requestteammatchlist.submit();
        }
    }

    public int getType() {
        return 795527;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof CRequestActivityAnswerQuestion;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestActivityAnswerQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
