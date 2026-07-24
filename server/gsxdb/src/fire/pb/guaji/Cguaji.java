//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.guaji;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.common.SCommon;
import fire.pb.main.ConfigManager;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.timer.ScheduledFutureMap;
import fire.pb.title.Title;
import gnet.link.Onlines;
import org.apache.log4j.Logger;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import mkdb.Mkdb;
import mkdb.Procedure;

public class Cguaji extends __Cguaji__ {
    public static final int PROTOCOL_TYPE = 800001;
    private static final Logger LOGGER = Logger.getLogger(Cguaji.class);
    public int ready;
    public List<Integer> leixing;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            GuajiMetricsReporter.ensureStartedAsync();
            (new Procedure() {
                protected boolean process() {
                    Title title = new Title(roleId, false);
                    if (Cguaji.this.ready == 10086) {
                        GuajiMetrics.recordStartAttempt("client");
                        ScheduledFuture scheduledFuture = ScheduledFutureMap.getRoleFuture(roleId);
                        if (scheduledFuture != null) {
                            scheduledFuture.cancel(true);
                            ScheduledFutureMap.removeRoleFuture(roleId);
                            MessageMgr.psendMsgNotify(roleId, 201035, (List)null);
                            GuajiMetrics.recordStop("manual_toggle");
                            if (LOGGER.isInfoEnabled()) {
                                LOGGER.info("guaji_stop|reason=manual_toggle|roleId=" + roleId);
                            }
                            return true;
                        }

                        Role role = RoleManager.getInstance().getRoleByID(roleId);
                        Team team = TeamManager.selectTeamByRoleId(roleId);
                        if (!team.isTeamLeader(roleId)) {
                            MessageMgr.psendMsgNotify(roleId, 201032, (List)null);
                            GuajiMetrics.recordStartFailure("not_team_leader");
                            if (LOGGER.isInfoEnabled()) {
                                LOGGER.info("guaji_start_failure|reason=not_team_leader|roleId=" + roleId);
                            }
                            return false;
                        }

                        SCommon titleConfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(655);
                        int matchedTitleCount = 0;

                        for(int i = 0; i < titleConfig.getValue().split(";").length; ++i) {
                            if (title.roleHaveTitle(Integer.parseInt(titleConfig.getValue().split(";")[i]))) {
                                ++matchedTitleCount;
                            }
                        }

                        if (matchedTitleCount == 0) {
                            MessageMgr.psendMsgNotify(roleId, 201031, (List)null);
                            GuajiMetrics.recordStartFailure("title_missing");
                            if (LOGGER.isInfoEnabled()) {
                                LOGGER.info("guaji_start_failure|reason=title_missing|roleId=" + roleId);
                            }
                            return false;
                        }

                        SCommon periodConfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(656);
                        scheduledFuture = Mkdb.executor().scheduleAtFixedRate(new Guajitask(roleId, Cguaji.this.leixing, role.getMapId()), 1L, Long.parseLong(periodConfig.getValue()), TimeUnit.SECONDS);
                        ScheduledFutureMap.setRoleFuture(roleId, scheduledFuture);
                        GuajiMetrics.recordStartSuccess("client");
                        if (LOGGER.isInfoEnabled()) {
                            LOGGER.info("guaji_start|roleId=" + roleId + "|points=" + Cguaji.this.leixing + "|periodSec=" + periodConfig.getValue());
                        }
                        MessageMgr.psendMsgNotify(roleId, 201034, (List)null);
                    } else if (LOGGER.isDebugEnabled()) {
                        LOGGER.debug("ignore_guaji_request|roleId=" + roleId + "|ready=" + Cguaji.this.ready);
                    }

                    return true;
                }
            }).submit();
        }

    }

    public int getType() {
        return 800001;
    }

    public Cguaji() {
        this.leixing = new ArrayList<>();
    }

    public Cguaji(int ready, List<Integer> typeList, int unused) {
        this.ready = ready;
        this.leixing = typeList;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            var1.marshal(this.ready);
            var1.marshal((Marshal)this.leixing);
            return var1;
        }
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        this.ready = var1.unmarshal_int();

        for(int var2 = var1.uncompact_uint32(); var2 > 0; --var2) {
            int var3 = var1.unmarshal_int();
            this.leixing.add(var3);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else if (var1 instanceof Cguaji) {
            Cguaji var2 = (Cguaji)var1;
            if (this.ready != var2.ready) {
                return false;
            } else {
                return this.leixing == var2.leixing;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int var1 = 0;
        var1 += this.ready;
        var1 += this.leixing.hashCode();
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(this.ready).append(",");
        var1.append(")");
        var1.append("'").append(this.leixing).append("'");
        var1.append(")");
        return var1.toString();
    }

    public int compareTo(Cguaji var1) {
        if (var1 == this) {
            return 0;
        } else {
            int var2 = 0;
            var2 = this.ready - var1.ready;
            return 0 != var2 ? var2 : var2;
        }
    }
}
