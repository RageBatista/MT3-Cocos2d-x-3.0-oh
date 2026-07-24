//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import fire.pb.SRefreshUserExp;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.RoleImpl;
import fire.pb.main.ConfigManager;
import java.util.Map;
import mkdb.Procedure;
import xbean.Properties;

public class PReturnPotentialFruit extends Procedure {
    final long roleId;
    final int location;

    public PReturnPotentialFruit(long roleId, int location) {
        this.roleId = roleId;
        this.location = location;
    }

    public boolean process() {
        Properties properties = xtable.Properties.get(this.roleId);
        if (properties == null) {
            return false;
        } else if (!properties.getQlgmap().containsKey(this.location)) {
            return false;
        } else {
            SQiannengguoLevelUp levelUp = (SQiannengguoLevelUp)ConfigManager.getInstance().getConf(SQiannengguoLevelUp.class).get(this.location);
            properties.getQlgmap().remove(this.location);
            properties.setExp(properties.getExp() + (long)levelUp.returnvalue);
            Procedure.psendWhileCommit(this.roleId, new SRefreshUserExp(properties.getExp()));
            SQiannengguoextra qiannengguoextra = PotentialMgr.getExtra(properties);
            if (qiannengguoextra != null) {
                if (properties.getQlgextrapromap().containsKey(qiannengguoextra.needcount)) {
                    properties.setQlgcurrextra(qiannengguoextra.needcount);
                }
            } else {
                properties.getQlgextrapromap().clear();
                properties.setQlgcurrextra(0);
            }

            RoleImpl role = new RoleImpl(this.roleId);
            Map<Integer, Float> integerFloatMap = role.updateAllFinalAttrs();
            role.updateScore();
            SRefreshRoleData send = new SRefreshRoleData();
            send.datas.putAll(integerFloatMap);
            Procedure.psendWhileCommit(this.roleId, send);
            SyncPotentialFruit fruit = role.getPotentialFruitProtocol();
            Procedure.psendWhileCommit(this.roleId, fruit);
            return true;
        }
    }
}
