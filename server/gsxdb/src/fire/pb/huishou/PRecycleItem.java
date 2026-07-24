package fire.pb.huishou;

import fire.pb.item.BagTypes;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import fire.log.enums.YYLoggerTuJingEnum;
import mkdb.Procedure;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * 处理客户端物品回收请求的核心流程。
 * 协议：800016（触手项）
 */
public class PRecycleItem extends Procedure {
    private static final Logger logger = Logger.getLogger("HUISHOU");

    private final long roleId;
    private final int packId;
    private final int keyInPack;
    private final int recycleMode; // 0=单个回收, 1=批量回收

    public PRecycleItem(long roleId, int packId, int keyInPack, int recycleMode) {
        this.roleId = roleId;
        this.packId = packId;
        this.keyInPack = keyInPack;
        this.recycleMode = recycleMode;
    }

    @Override
    protected boolean process() throws Exception {
        // 1. 参数校验
        if (packId != BagTypes.BAG) {
            logger.warn("角色 " + roleId + " 尝试回收非背包物品, packId: " + packId);
            return false;
        }

        // 2. 获取背包容器
        ItemMaps bag = Module.getInstance().getItemMaps(roleId, packId, false);
        if (bag == null) {
            logger.error("角色 " + roleId + " 回收物品时找不到背包, packId: " + packId);
            return false;
        }

        // 3. 获取要回收的主物品
        ItemBase mainItem = bag.getItem(keyInPack);
        if (mainItem == null) {
            MessageMgr.sendMsgNotify(roleId, 140018, null); // 物品不存在
            return false;
        }

        // 4. 检查物品是否可回收
        HuiShouConfig config = HuiShouManager.getConfig(mainItem.getItemId());
        if (config == null || config.canhuishou != 1) {
            MessageMgr.sendMsgNotify(roleId, 145005, null); // 此物品不能被回收
            logger.warn("角色 " + roleId + " 尝试回收不可回收的物品, itemId: " + mainItem.getItemId());
            return false;
        }
        
        // 5. 确定要回收的物品列表和总数量
        Map<Integer, Integer> itemsToRemove = new HashMap<>();
        int totalCount;

        if (recycleMode == 0) { // 单个回收
            totalCount = 1;
            itemsToRemove.put(keyInPack, 1);
        } else { // 批量回收: 回收背包中所有同ID的物品
            totalCount = 0;
            for (ItemBase item : bag) {
                if (item.getItemId() == mainItem.getItemId()) {
                    itemsToRemove.put(item.getKey(), item.getNumber());
                    totalCount += item.getNumber();
                }
            }
        }

        if (totalCount == 0) {
            return false; // 理论上不会发生
        }

        // 6. 移除物品
        int removedCount = 0;
        for (Map.Entry<Integer, Integer> e : itemsToRemove.entrySet()) {
            int key = e.getKey();
            int num = e.getValue();
            removedCount += bag.removeItemWithKey(key, num, YYLoggerTuJingEnum.GENERAL, 0, "回收扣除");
        }

        if (removedCount != totalCount) {
            logger.error("角色 " + roleId + " 回收物品时移除数量异常. 预期: " + totalCount + ", 实际: " + removedCount);
            MessageMgr.sendMsgNotify(roleId, 142969, null);
            return false;
        }

        // 7. 计算并 发放奖励
        long totalRewardCount = (long) config.huishouitemnum * totalCount;
        if (totalRewardCount <= 0) {
            logger.warn("角色 " + roleId + " 回收物品 " + mainItem.getItemId() + " x" + totalCount + " 但计算出的奖励数量为0。");
            // 即使奖励为0，也认为流程成功
            sendSuccessMsg();
            return true;
        }

        int addedCount = BagUtil.addItem(roleId, config.huishouitemid, (int) totalRewardCount, "回收奖励", YYLoggerTuJingEnum.GENERAL, 0);
        if (addedCount <= 0 && totalRewardCount > 0) {
            logger.error("角色 " + roleId + " 回收物品后发放奖励失败. 奖励物品ID: " + config.huishouitemid + ", 数量: " + totalRewardCount);
        }

        // 8. 发送成功消息给客户端
        sendSuccessMsg();

        logger.info("角色 " + roleId + " 成功回收物品. 物品ID: " + mainItem.getItemId() + ", 数量: " + totalCount +
                ". 获得奖励物品ID: " + config.huishouitemid + ", 数量: " + totalRewardCount);

        return true;
    }

    /**
     * 发送回收成功协议给客户端
     * @param addedItems 实际添加到背包的物品<物品ID, 数量>
     */
    private void sendSuccessMsg() {
        // TODO: 这里需要创建一个服务器->客户端的成功协议 (e.g., SRecycleItemResult)
        // 协议中应包含回收获得的物品ID和数量，以便客户端弹出 "恭喜您获得..." 的提示。
        // SRecycleItemResult resultMsg = new SRecycleItemResult();
        // resultMsg.reward_item_id = config.huishouitemid;
        // resultMsg.reward_item_count = totalRewardCount;
        // gnet.link.Onlines.getInstance().send(roleId, resultMsg);

        // 临时用系统消息提示
        MessageMgr.sendMsgNotify(roleId, 145006, null); // 回收成功
    }
}
