//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.msp.move.GRoleEquipChange;
import fire.pb.GsClient;
import fire.pb.course.CourseManager;
import fire.pb.main.ConfigManager;
import fire.pb.npc.SRide;
import fire.pb.npc.SRideItem;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import mkdb.Procedure;
import xbean.Properties;
import xtable.Roleid2teamid;

public class PTransformationEquip extends Procedure {
    private long roleId;
    private int equipId;
    private int chageType;
    private int state;

    public PTransformationEquip(long roleid, int equipid, int state) {
        this.roleId = roleid;
        this.equipId = equipid;
        this.state = state;
    }

    protected boolean process() {
        Properties properties = xtable.Properties.get(this.roleId);
        int rideId = 0;
        if (this.state == 1) {
            rideId = this.equipId;
        }

        properties.setRide(rideId);
        SRideItem sRideItem = (SRideItem)ConfigManager.getInstance().getConf(SRideItem.class).get(rideId);
        if (sRideItem != null) {
            SRide sRide = (SRide)ConfigManager.getInstance().getConf(SRide.class).get(sRideItem.getRideid());
            if (sRide != null) {
                refreshRide(this.roleId, sRide.ridemodel, sRide.id, this.equipId);
                CourseManager.achieveUpdate(this.roleId, 27);
                return true;
            }
        }

        refreshRide(this.roleId, 0, 0, 0);
        return true;
    }

    public static void refreshRide(final long roleId, int ride, int rideid, int itemid) {
        GRoleEquipChange notifymap = new GRoleEquipChange();
        notifymap.roleid = roleId;
        notifymap.pos = -1;
        notifymap.itemid = 0;
        notifymap.ride = ride;
        notifymap.effect = -1;
        GsClient.pSendWhileCommit(notifymap);
        SRideUpdate msg = new SRideUpdate();
        msg.rideid = rideid;
        msg.itemid = itemid;
        Procedure.psendWhileCommit(roleId, msg);
        Long teamId = Roleid2teamid.get(roleId);
        if (teamId != null) {
            Procedure.pexecuteWhileCommit(new Procedure() {
                protected boolean process() throws Exception {
                    Team team = TeamManager.selectTeamByRoleId(roleId);
                    if (team != null) {
                        team.updateTeamMemberComponents2Others(roleId);
                    }

                    return true;
                }
            });
        }

    }
}
