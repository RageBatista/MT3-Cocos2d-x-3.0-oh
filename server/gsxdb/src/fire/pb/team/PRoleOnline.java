//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.PropRole;
import fire.pb.circletask.catchit.PCatchItRoleOnlineProc;
import fire.pb.huoban.PUpdateHuoBanZhenRong;
import fire.pb.huoban.SChangeZhenrong;
import fire.pb.mission.SNpcFollowStart;
import fire.pb.mission.UtilHelper;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.HuoBanColumn;
import xbean.HuoBanZhenrong;
import xbean.HuoBanZhenrongInfo;
import xbean.Pod;
import xtable.Huobancolumns;
import xtable.Huobanzhenrongs;
import xtable.Locks;
import xtable.Roleid2teamid;

public class PRoleOnline extends Procedure {
    private long roleId;

    public PRoleOnline(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() {
        PropRole prole = new PropRole(this.roleId, true);
        SSetMyFormation sSetMyFormation = new SSetMyFormation();
        sSetMyFormation.formation = prole.getDealutFormId();
        sSetMyFormation.entersend = 1;
        Procedure.psendWhileCommit(this.roleId, sSetMyFormation);
        int follownpc = UtilHelper.getFollowid(this.roleId);
        if (follownpc > 0) {
            SNpcFollowStart snpcfollow = new SNpcFollowStart();
            snpcfollow.npcid = follownpc;
            Procedure.psendWhileCommit(this.roleId, snpcfollow);
        }

        HuoBanZhenrong hbzhenrongs = Huobanzhenrongs.select(this.roleId);
        if (hbzhenrongs == null) {
            HuoBanColumn huobancol = Huobancolumns.select(this.roleId);
            if (huobancol != null) {
                Procedure.pexecute(new PUpdateHuoBanZhenRong(this.roleId, (new PropRole(this.roleId, true)).getDealutFormId(), 1, huobancol.getFighthuobans(), 4));
            }
        } else {
            SChangeZhenrong snd = new SChangeZhenrong();
            HuoBanZhenrongInfo info = (HuoBanZhenrongInfo)hbzhenrongs.getZhenrong().get(hbzhenrongs.getCurrent());
            if (info == null) {
                info = Pod.newHuoBanZhenrongInfo();
                info.setZhenfa((new PropRole(this.roleId, true)).getDealutFormId());
                hbzhenrongs.getZhenrong().put(hbzhenrongs.getCurrent(), info);
            }

            snd.zhenrong = hbzhenrongs.getCurrent();
            snd.zhenfa = info.getZhenfa();
            snd.huobanlist.addAll(info.getHuoban());
            snd.reason = 1;
            Procedure.psendWhileCommit(this.roleId, snd);
        }

        Long teamId = Roleid2teamid.select(this.roleId);
        if (teamId == null) {
            return true;
        } else {
            try {
                Team team = new Team(teamId, false);
                this.lock(Lockeys.get(Locks.ROLELOCK, team.getAllMemberIds()));
                if (team.isInTeam(this.roleId)) {
                    team.roleOnline(this.roleId);
                }

                (new PCatchItRoleOnlineProc(this.roleId)).call();
            } catch (Exception e) {
                TeamManager.logger.error(e);
            }

            return true;
        }
    }
}
