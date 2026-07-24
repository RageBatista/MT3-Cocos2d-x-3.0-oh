//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.clan.ClanUtils;
import fire.pb.instancezone.Module;
import fire.pb.instancezone.conf.InstanceZoneConfig;
import xbean.ClanInfo;
import xbean.ClanInstances;
import xtable.Claninstances;

public class RoleClanInstanceState implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        ClanInfo clanInfo = ClanUtils.getClanInfoById(roleid, true);
        if (null == clanInfo) {
            return false;
        } else {
            ClanInstances clanInst = Claninstances.select(clanInfo.getKey());
            if (clanInst == null) {
                return false;
            } else {
                InstanceZoneConfig zoneconfig = (InstanceZoneConfig)Module.getInstance().getInstanceZoneConfigs().get(args1);
                if (zoneconfig == null) {
                    return false;
                } else {
                    Long instanceKey = (Long)clanInst.getInstkey().get(args1);
                    if (instanceKey != null) {
                        return true;
                    } else {
                        return zoneconfig.beforeZoneId == 0 || (Integer)clanInst.getInststate().get(zoneconfig.beforeZoneId) == 1;
                    }
                }
            }
        }
    }
}
