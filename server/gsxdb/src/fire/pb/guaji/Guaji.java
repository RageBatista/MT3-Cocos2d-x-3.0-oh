package fire.pb.guaji;

import fire.pb.common.SCommon;
import fire.pb.main.ConfigManager;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.timer.ScheduledFutureMap;
import fire.pb.title.Title;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import mkdb.Mkdb;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class Guaji extends Procedure {
    private static final Logger LOGGER = Logger.getLogger(Guaji.class);

    private static final int READY_TOGGLE = 10086;

    private static final int MSG_STOP = 201035;
    private static final int MSG_INVALID_TYPE = 201029;
    private static final int MSG_NOT_TEAM_LEADER = 201032;
    private static final int MSG_START = 201034;
    private static final int MSG_TITLE_MISSING = 201031;

    private final long roleId;
    private final int ready;
    private final List<Integer> leixing;

    public Guaji(long roleId, int ready, int leixing) {
        this(roleId, ready, leixing <= 0 ? Collections.<Integer>emptyList() : singletonList(leixing));
    }

    public Guaji(long roleId, int ready, List<Integer> leixing) {
        this.roleId = roleId;
        this.ready = ready;
        this.leixing = leixing == null ? Collections.<Integer>emptyList() : leixing;
    }

    @Override
    protected boolean process() {
        GuajiMetricsReporter.ensureStartedAsync();
        if (this.ready != READY_TOGGLE) {
            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("ignore_guaji_request|source=gm|roleId=" + this.roleId + "|ready=" + this.ready);
            }
            return true;
        }

        GuajiMetrics.recordStartAttempt("gm");
        ScheduledFuture future = ScheduledFutureMap.getRoleFuture(this.roleId);
        if (future != null) {
            future.cancel(true);
            ScheduledFutureMap.removeRoleFuture(this.roleId);
            MessageMgr.psendMsgNotify(this.roleId, MSG_STOP, (List)null);
            GuajiMetrics.recordStop("manual_toggle");
            if (LOGGER.isInfoEnabled()) {
                LOGGER.info("guaji_stop|source=gm|reason=manual_toggle|roleId=" + this.roleId);
            }
            return true;
        }

        if (this.leixing.isEmpty()) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_INVALID_TYPE, (List)null);
            GuajiMetrics.recordStartFailure("invalid_guaji_type");
            if (LOGGER.isInfoEnabled()) {
                LOGGER.info("guaji_start_failure|source=gm|reason=invalid_guaji_type|roleId=" + this.roleId);
            }
            return false;
        }

        Role role = RoleManager.getInstance().getRoleByID(this.roleId);
        Team team = TeamManager.selectTeamByRoleId(this.roleId);
        if (team != null && !team.isTeamLeader(this.roleId)) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_NOT_TEAM_LEADER, (List)null);
            GuajiMetrics.recordStartFailure("not_team_leader");
            if (LOGGER.isInfoEnabled()) {
                LOGGER.info("guaji_start_failure|source=gm|reason=not_team_leader|roleId=" + this.roleId);
            }
            return false;
        }

        Title title = new Title(this.roleId, false);
        if (!hasRequiredTitle(title)) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_TITLE_MISSING, (List)null);
            GuajiMetrics.recordStartFailure("title_missing");
            if (LOGGER.isInfoEnabled()) {
                LOGGER.info("guaji_start_failure|source=gm|reason=title_missing|roleId=" + this.roleId);
            }
            return false;
        }

        long periodSec = 15L;
        try {
            SCommon periodCfg = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(656);
            if (periodCfg != null) {
                periodSec = Long.parseLong(periodCfg.getValue());
            }
        } catch (Exception ignored) {
        }

        ScheduledFuture newFuture = Mkdb.executor().scheduleAtFixedRate(new Guajitask(this.roleId, this.leixing, role.getMapId()), 1L, periodSec, TimeUnit.SECONDS);
        ScheduledFutureMap.setRoleFuture(this.roleId, newFuture);
        MessageMgr.psendMsgNotify(this.roleId, MSG_START, (List)null);
        GuajiMetrics.recordStartSuccess("gm");
        if (LOGGER.isInfoEnabled()) {
            LOGGER.info("guaji_start|source=gm|roleId=" + this.roleId + "|points=" + this.leixing + "|periodSec=" + periodSec);
        }
        return true;
    }

    private static boolean hasRequiredTitle(Title title) {
        SCommon required = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(655);
        if (required != null && required.getValue() != null && required.getValue().trim().length() > 0) {
            String[] parts = required.getValue().split(";");
            for (int i = 0; i < parts.length; i++) {
                try {
                    int titleId = Integer.parseInt(parts[i]);
                    if (title.roleHaveTitle(titleId)) {
                        return true;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            return false;
        }

        return title.roleHaveTitle(439) || title.roleHaveTitle(440) || title.roleHaveTitle(441) || title.roleHaveTitle(442);
    }

    private static List<Integer> singletonList(int value) {
        ArrayList<Integer> list = new ArrayList<>(1);
        list.add(value);
        return list;
    }
}
