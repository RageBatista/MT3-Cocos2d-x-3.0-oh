//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.winner.WinnerManager;
import fire.pb.activity.winner.WinnerRecord;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.TaskDlgUtil;
import gnet.link.Onlines;
import java.util.Arrays;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;
import xbean.TaskDlgInfo;

public class CWinnerChangeTask extends __CWinnerChangeTask__ {
    public static final int PROTOCOL_TYPE = 795484;
    public int acceptflag;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    Team team = TeamManager.selectTeamByRoleId(roleid);
                    if (team == null) {
                        MessageMgr.sendMsgNotify(roleid, 140498, (List)null);
                        return false;
                    } else {
                        long currentTime = System.currentTimeMillis();
                        if (!WinnerManager.getInstance().isInWinnerActiveTime(currentTime)) {
                            return false;
                        } else {
                            if (CWinnerChangeTask.this.acceptflag == 1) {
                                long teamleadid = team.getTeamLeaderId();
                                TaskDlgInfo task = TaskDlgUtil.getTaskDlgInfo(teamleadid, 701002);
                                if (task == null) {
                                    WinnerManager.logger.info("角色id " + roleid + "\t同步冠军试炼任务，数据错误，队长没有任务");
                                    return false;
                                }

                                Npc npc = SceneNpcManager.selectNpcByKey(task.getDstnpckey());
                                if (npc == null) {
                                    return false;
                                }

                                if (TaskDlgUtil.existTask(roleid, 701002) || TaskDlgUtil.existTask(roleid, 701001)) {
                                    WinnerManager.getInstance().abandonWinnerTask(roleid);
                                }

                                WinnerManager.getInstance().createWinnerTask(701002, roleid, npc, 4, 0, task.getSumnum());
                                WinnerManager.getInstance().addWinnerRole(roleid);
                                MessageMgr.psendMsgNotifyWhileCommit(roleid, 140666, npc.getNpcID(), Arrays.asList(task.getSumnum() + "", npc.getName()));
                                WinnerRecord record = (WinnerRecord)WinnerManager.getInstance().teams.get(team.getTeamId());
                                if (record != null) {
                                    record.setTeamScore(0);
                                    record.setRound(0);
                                    WinnerManager.getInstance().removeLastTeamidAddNew(record, roleid);
                                }

                                Properties prop = xtable.Properties.select(roleid);

                                for(Long mem : team.getNormalMemberIds()) {
                                    WinnerManager.clearActiveTeamWinnerScore(mem);
                                    MessageMgr.sendMsgNotify(mem, 170019,Arrays.<String>asList(prop.getRolename()));
                                }

                                WinnerManager.logger.info("角色id " + roleid + "\t同步冠军试炼任务，成功");
                            } else {
                                Properties prop = xtable.Properties.select(roleid);

                                for(Long mem : team.getNormalMemberIds()) {
                                    MessageMgr.sendMsgNotify(mem, 160449,Arrays.<String>asList(prop.getRolename()));
                                }
                            }

                            return true;
                        }
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 795484;
    }

    public CWinnerChangeTask() {
    }

    public CWinnerChangeTask(int _acceptflag_) {
        this.acceptflag = _acceptflag_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.acceptflag);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.acceptflag = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CWinnerChangeTask) {
            CWinnerChangeTask _o_ = (CWinnerChangeTask)_o1_;
            return this.acceptflag == _o_.acceptflag;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.acceptflag;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.acceptflag).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CWinnerChangeTask _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.acceptflag - _o_.acceptflag;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
