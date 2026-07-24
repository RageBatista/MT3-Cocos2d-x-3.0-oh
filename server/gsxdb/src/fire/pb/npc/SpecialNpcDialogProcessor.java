//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import gnet.link.Onlines;
import mkdb.Procedure;
import mkdb.Transaction;

public class SpecialNpcDialogProcessor {
    protected SVisitNpcContainChatMsg chatMsg = null;
    protected long roleid;
    protected long npcKey;

    public SpecialNpcDialogProcessor(long roleid, long npcKey) {
        this.roleid = roleid;
        this.npcKey = npcKey;
    }

    public void onVisitNpc() {
        if (null != this.chatMsg) {
            if (Transaction.current() != null) {
                Procedure.psendWhileCommit(this.roleid, this.chatMsg);
            } else {
                Onlines.getInstance().send(this.roleid, this.chatMsg);
            }
        }

    }
}
