//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.List;
import mkdb.Procedure;
import xbean.PetInfo;

public class DoneWhileSubmitPet<T extends Procedure> implements Procedure.Done<T> {
    private final long roleid;
    private final List<PetInfo> pis;
    private final int questid;

    public DoneWhileSubmitPet(long roleid, int questid, List<PetInfo> pis) {
        this.roleid = roleid;
        this.questid = questid;
        this.pis = pis;
    }

    public void doDone(T p) {
        if (this.pis != null && p.isSuccess()) {
        }

    }
}
