//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import mkdb.Procedure;
import xbean.Pod;
import xbean.ServerRoles;
import xtable.Rolenumfornewserver;

public class PAddRoleNum extends Procedure {
    protected boolean process() throws Exception {
        ServerRoles serverRoles = Rolenumfornewserver.get(1);
        if (serverRoles == null) {
            serverRoles = Pod.newServerRoles();
            Rolenumfornewserver.insert(1, serverRoles);
        } else {
            serverRoles.setRolenum(serverRoles.getRolenum() + 1);
            if (serverRoles.getRolenum() <= 1000) {
                serverRoles.setCreatetime(System.currentTimeMillis());
            }
        }

        return true;
    }
}
