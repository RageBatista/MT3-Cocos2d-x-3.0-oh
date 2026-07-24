package fire.pb.huishou;

import gnet.link.Onlines;
import mkdb.Procedure;

/** 查询回购列表流程处理 */
public class PGetItemBuyBackList extends Procedure {
    private final long roleId;      // 玩家ID
    private final int findType;     // 查询类型: 1=普通, 3=限时, 4=历史
    private final int itemType;     // 物品类型: 1=装备, 2=道具
    private final int isTimeLimit;  // 是否限时: 0=否, 1=是
    private final int page;         // 页码(从1开始)
    private final int pageSize;     // 每页大小

    public PGetItemBuyBackList(long roleId, int findType, int itemType,
                               int isTimeLimit, int page, int pageSize) {
        this.roleId = roleId;
        this.findType = findType;
        this.itemType = itemType;
        this.isTimeLimit = isTimeLimit;
        this.page = page;
        this.pageSize = pageSize;
    }

    @Override
    protected boolean process() throws Exception {
        if (Onlines.getInstance().find(roleId) == null) {
            return false;
        }

        BuyBackService.BuyBackQuery query = new BuyBackService.BuyBackQuery(
                roleId, findType, itemType, isTimeLimit, page, pageSize
        );

        BuyBackService.BuyBackListResult result = BuyBackService.queryList(query);

        SItemBuyBackList proto = new SItemBuyBackList();
        proto.findtype = result.findType;
        proto.itemtype = result.itemType;
        proto.istimelimit = result.isTimeLimit;
        proto.page = result.page;
        proto.pagesize = result.pageSize;
        proto.pagetotal = result.pageTotal;
        proto.itembuybackos.addAll(result.items);

        Onlines.getInstance().send(roleId, proto);
        return true;
    }
}
