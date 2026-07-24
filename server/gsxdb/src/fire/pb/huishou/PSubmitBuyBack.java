package fire.pb.huishou;

import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import mkdb.Procedure;

/** 回购提交流程处理 */
public class PSubmitBuyBack extends Procedure {

    private final long roleId;      // 玩家ID
    private final int itemId;       // 物品ID
    private final int itemType;     // 物品类型: 1=装备, 2=道具
    private final int isTimeLimit;  // 是否限时: 0=否, 1=是
    private final int num;          // 回购数量(1-99)

    public PSubmitBuyBack(long roleId, int itemId, int itemType,
                          int isTimeLimit, int num) {
        this.roleId = roleId;
        this.itemId = itemId;
        this.itemType = itemType;
        this.isTimeLimit = isTimeLimit;
        this.num = num;
    }

    @Override
    protected boolean process() throws Exception {
        if (roleId <= 0L) {
            return false;
        }
        if (Onlines.getInstance().find(roleId) == null) {
            return false;
        }

        BuyBackService.BuyBackCommand cmd = new BuyBackService.BuyBackCommand(
                roleId, itemId, itemType, isTimeLimit, num
        );

        BuyBackService.BuyBackSubmitResult result = BuyBackService.submit(cmd);
        if (!result.success) {
            MessageMgr.sendMsgNotify(roleId, 201070, null);
            return false;
        }

        SSubmitBuyBack proto = new SSubmitBuyBack();
        proto.itemid = itemId;
        proto.itemnum = result.remainInBag;
        proto.backnum = result.remainDaily;
        Onlines.getInstance().send(roleId, proto);

        return true;
    }
}
