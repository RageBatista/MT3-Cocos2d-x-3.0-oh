//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.zuoqi;

import fire.pb.item.ItemBase;
import fire.pb.item.Module;
import fire.pb.item.PEquipRideProc;
import mkdb.Procedure;

public class shiyong extends Procedure {
    private long roleId;
    public int zuoqiid;

    public shiyong(long roleId, int zuoqiid) {
        this.roleId = roleId;
        this.zuoqiid = zuoqiid;
    }

    protected boolean process() {
        ItemBase itemBase = Module.getInstance().getItemManager().genItemBase(this.zuoqiid, 1, 0);
        itemBase.bind();
        Procedure.pexecuteWhileCommit(new PEquipRideProc(this.roleId, this.zuoqiid, itemBase.getKey()));
        return true;
    }
}
