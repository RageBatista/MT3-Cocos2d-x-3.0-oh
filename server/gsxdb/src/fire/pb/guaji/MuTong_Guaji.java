package fire.pb.guaji;

import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.timer.ScheduledFutureMap;
import fire.pb.title.Title;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import mkdb.Mkdb;
import mkdb.Procedure;

public class MuTong_Guaji extends Procedure {
    private static final int READY_TOGGLE = 10086;

    private static final int MSG_STOP = 201035;
    private static final int MSG_INVALID_TYPE = 201029;
    private static final int MSG_NOT_TEAM_LEADER = 201032;
    private static final int MSG_START = 201034;
    private static final int MSG_TITLE_MISSING = 201031;

    private final long roleId;
    private final int ready;
    private final int leixing;

    public MuTong_Guaji(long roleId, int ready, int leixing) {
        this.roleId = roleId;
        this.ready = ready;
        this.leixing = leixing;
    }

    @Override
    protected boolean process() {
        if (this.ready != READY_TOGGLE) {
            return true;
        }

        ScheduledFuture future = ScheduledFutureMap.getRoleFuture(this.roleId);
        if (future != null) {
            future.cancel(true);
            ScheduledFutureMap.removeRoleFuture(this.roleId);
            MessageMgr.psendMsgNotify(this.roleId, MSG_STOP, (List)null);
            return true;
        }

        if (this.leixing == 0) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_INVALID_TYPE, (List)null);
            return false;
        }

        Role role = RoleManager.getInstance().getRoleByID(this.roleId);
        Team team = TeamManager.selectTeamByRoleId(this.roleId);
        if (team != null && !team.isTeamLeader(this.roleId)) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_NOT_TEAM_LEADER, (List)null);
            return false;
        }

        Title title = new Title(this.roleId, false);
        if (!title.roleHaveTitle(439) && !title.roleHaveTitle(440) && !title.roleHaveTitle(441) && !title.roleHaveTitle(442)) {
            MessageMgr.psendMsgNotify(this.roleId, MSG_TITLE_MISSING, (List)null);
            return false;
        }

        ScheduledFuture newFuture = Mkdb.executor().scheduleAtFixedRate(new MuTong_Guajitask(this.roleId, this.leixing, role.getMapId()), 1L, 15L, TimeUnit.SECONDS);
        ScheduledFutureMap.setRoleFuture(this.roleId, newFuture);
        MessageMgr.psendMsgNotify(this.roleId, MSG_START, (List)null);
        return true;
    }
}

