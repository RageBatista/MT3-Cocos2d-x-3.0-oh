//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import fire.pb.effect.RoleImpl;
import mkdb.Procedure;

public class PQueryPotentialFruit extends Procedure {
    final long roleId;

    public PQueryPotentialFruit(long roleId) {
        this.roleId = roleId;
    }

    public boolean process() {
        RoleImpl role = new RoleImpl(this.roleId);
        SyncPotentialFruit fruit = role.getPotentialFruitProtocol();
        Procedure.psendWhileCommit(this.roleId, fruit);
        return true;
    }
}
