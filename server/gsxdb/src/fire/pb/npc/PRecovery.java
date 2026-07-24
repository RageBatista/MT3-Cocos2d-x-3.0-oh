//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import mkdb.Procedure;

public abstract class PRecovery extends Procedure {
    protected final long roleid;
    protected final long npckey;

    public PRecovery(long roleid, long npckey) {
        this.roleid = roleid;
        this.npckey = npckey;
    }

    abstract boolean check();

    abstract void cost();

    abstract void recovery();

    protected final boolean process() {
        if (this.check()) {
            this.cost();
            this.recovery();
            return true;
        } else {
            return false;
        }
    }
}
