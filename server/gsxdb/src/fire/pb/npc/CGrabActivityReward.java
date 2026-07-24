//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.activity.award.RewardMgr;
import fire.pb.common.SCommon;
import fire.pb.main.ConfigManager;
import fire.pb.mission.activelist.RoleLiveness;
import fire.pb.talk.MessageMgr;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.ActivityQuestion;
import xtable.Roleid2activityquestion;

public class CGrabActivityReward extends __CGrabActivityReward__ {
    public static final int PROTOCOL_TYPE = 795531;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure grabactivityreward = new Procedure() {
                protected boolean process() {
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

                        if (activityquestion.getGrabreward() == 1) {
                            SCommon c = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(236);
                            int rewardid = Integer.parseInt(c.getValue());
                            Map<String, Object> paras = new HashMap(10);
                            paras.put("AnswerCnt", activityquestion.getAnswerrighttimes());
                            RewardMgr.getInstance().distributeAllAward(roleid, rewardid, paras, YYLoggerTuJingEnum.tujing_Value_grab, 0, 4002, "答题");
                            activityquestion.setGrabreward(2);
                            MessageMgr.sendMsgNotify(roleid, 160417, (List)null);
                            SGrabActivityReward msg = new SGrabActivityReward();
                            Procedure.psendWhileCommit(roleid, msg);
                        } else if (activityquestion.getGrabreward() == 2) {
                            MessageMgr.sendMsgNotify(roleid, 160418, (List)null);
                        } else if (activityquestion.getGrabreward() == 3) {
                            MessageMgr.sendMsgNotify(roleid, 160416, (List)null);
                        }
                    }

                    return true;
                }
            };
            grabactivityreward.submit();
        }
    }

    public int getType() {
        return 795531;
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
            return _o1_ instanceof CGrabActivityReward;
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

    public int compareTo(CGrabActivityReward _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
