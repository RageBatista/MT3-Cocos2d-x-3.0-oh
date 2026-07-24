//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import java.util.Arrays;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import mkdb.Transaction;
import xbean.ModifyNameRole;
import xbean.Pod;
import xtable.Locks;
import xtable.Modnameitemroles;
import xtable.Properties;

public class ModifyRoleNameManager {
    private static ModifyRoleNameManager instance = new ModifyRoleNameManager();
    public static final int MOD_NAME_ITEM_ID = 36752;

    private ModifyRoleNameManager() {
    }

    public static ModifyRoleNameManager getInstance() {
        return instance;
    }

    public void buyModNameItem(final long roleid) {
        Procedure buyItemProc = new Procedure() {
            protected boolean process() throws Exception {
                Integer userid = Properties.selectUserid(roleid);
                if (userid == null) {
                    return false;
                } else {
                    this.lock(Lockeys.get(Locks.USERLOCK, Arrays.asList(userid)));
                    this.lock(Lockeys.get(Locks.ROLELOCK, Arrays.asList(roleid)));
                    ModifyNameRole modRole = Modnameitemroles.get(roleid);
                    if (modRole == null) {
                        modRole = Pod.newModifyNameRole();
                        modRole.setLastbuytime(System.currentTimeMillis());
                        Modnameitemroles.insert(roleid, modRole);
                    } else if (System.currentTimeMillis() - modRole.getLastbuytime() < 2592000000L) {
                        MessageMgr.psendMsgNotifyWhileRollback(roleid, 144660, (List)null);
                        return false;
                    }

                    ItemMaps depot = Module.getInstance().getItemMaps(roleid, 2, true);
                    ItemMaps bag = Module.getInstance().getItemMaps(roleid, 1, true);
                    ItemMaps temp = Module.getInstance().getItemMaps(roleid, 4, true);
                    if (bag.getItemNum(36752, 0) <= 0 && depot.getItemNum(36752, 0) <= 0 && temp.getItemNum(36752, 0) <= 0) {
                        int modCount = modRole.getBuycount() % 5;
                        int timeGap = (int)((System.currentTimeMillis() - modRole.getLastbuytime()) / 5184000000L);
                        int needFushi = 6888 + 3000 * modCount - 3000 * timeGap;
                        if (needFushi < 6888) {
                            needFushi = 6888;
                        }

                        modRole.setBuycount(modRole.getBuycount() + 1);
                        modRole.setLastbuytime(System.currentTimeMillis());
                        return true;
                    } else {
                        MessageMgr.psendMsgNotifyWhileRollback(roleid, 144659, (List)null);
                        return false;
                    }
                }
            }
        };
        if (Transaction.current() == null) {
            buyItemProc.submit();
        } else {
            buyItemProc.call();
        }

    }

    public void sendPriceInfo(long roleid, long npckey) {
        if (SceneNpcManager.checkDistance(npckey, roleid)) {
            ;
        }
    }
}
