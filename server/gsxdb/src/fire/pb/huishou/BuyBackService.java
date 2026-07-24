package fire.pb.huishou;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.fushi.PAddFuShi;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Pod;
import xbean.RoleTradingHisRecord;
import xbean.RoleTradingHisRecordList;
import xbean.RoleTradingRecord;
import xtable.Roletradinghisrecordlisttab;
import xtable.Roletradingrecordstab;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 物品回购核心业务服务
 * 功能: 查询回购列表(配置+额度+历史), 提交回购(扣物品+发货币/符石+记录)
 * 架构: 协议层(819407/819409) → 流程层(P*) → 服务层(本类)
 */
public final class BuyBackService {

    private static final Logger logger = Logger.getLogger("HUISHOU");

    private static final int HISTORY_MAX_COUNT = 100;

    private BuyBackService() {
    }

    /** 回购列表查询参数 */
    public static final class BuyBackQuery {
        public final long roleId;     // 玩家ID
        public final int findType;    // 查询类型: 1=普通, 3=限时, 4=历史
        public final int itemType;    // 物品类型: 1=装备, 2=道具
        public final int isTimeLimit; // 是否限时: 0=否, 1=是
        public final int page;        // 页码(从1开始)
        public final int pageSize;    // 每页大小

        public BuyBackQuery(long roleId, int findType, int itemType,
                            int isTimeLimit, int page, int pageSize) {
            this.roleId = roleId;
            this.findType = findType;
            this.itemType = itemType;
            this.isTimeLimit = isTimeLimit;
            this.page = page;
            this.pageSize = pageSize;
        }
    }

    /** 回购列表查询结果 */
    public static final class BuyBackListResult {
        public final int findType;                // 查询类型
        public final int itemType;                // 物品类型
        public final int isTimeLimit;             // 是否限时
        public final int page;                    // 当前页码
        public final int pageSize;                // 每页大小
        public final int pageTotal;               // 总页数
        public final List<ItemBuyBackOs> items;   // 回购物品列表

        public BuyBackListResult(int findType, int itemType, int isTimeLimit,
                                 int page, int pageSize, int pageTotal,
                                 List<ItemBuyBackOs> items) {
            this.findType = findType;
            this.itemType = itemType;
            this.isTimeLimit = isTimeLimit;
            this.page = page;
            this.pageSize = pageSize;
            this.pageTotal = pageTotal;
            this.items = items;
        }
    }

    /** 回购提交参数 */
    public static final class BuyBackCommand {
        public final long roleId;     // 玩家ID
        public final int itemId;      // 物品ID
        public final int itemType;    // 物品类型: 1=装备, 2=道具
        public final int isTimeLimit; // 是否限时: 0=否, 1=是
        public final int num;         // 回购数量(1-99)

        public BuyBackCommand(long roleId, int itemId, int itemType,
                              int isTimeLimit, int num) {
            this.roleId = roleId;
            this.itemId = itemId;
            this.itemType = itemType;
            this.isTimeLimit = isTimeLimit;
            this.num = num;
        }
    }

    /** 回购提交结果 */
    public static final class BuyBackSubmitResult {
        public final boolean success;     // 是否成功
        public final String message;      // 错误信息(成功时为"OK")
        public final int remainInBag;     // 背包剩余数量
        public final int remainDaily;     // 当日剩余额度

        private BuyBackSubmitResult(boolean success, String message,
                                    int remainInBag, int remainDaily) {
            this.success = success;
            this.message = message;
            this.remainInBag = remainInBag;
            this.remainDaily = remainDaily;
        }

        public static BuyBackSubmitResult ok(int remainInBag, int remainDaily) {
            return new BuyBackSubmitResult(true, "OK", remainInBag, remainDaily);
        }

        public static BuyBackSubmitResult fail(String message) {
            return new BuyBackSubmitResult(false, message, 0, 0);
        }
    }

    /**
     * 查询回购列表。
     */
    public static BuyBackListResult queryList(BuyBackQuery query) {
        if (query.page <= 0 || query.pageSize <= 0) {
            return new BuyBackListResult(
                    query.findType, query.itemType, query.isTimeLimit,
                    query.page, query.pageSize, 0, new ArrayList<ItemBuyBackOs>(0)
            );
        }

        // findType == 4: 回购记录
        if (query.findType == 4) {
            return queryHistoryList(query);
        }

        return queryConfigList(query);
    }

    /**
     * 提交一次回购请求。
     */
    public static BuyBackSubmitResult submit(BuyBackCommand cmd) {
        if (cmd.num <= 0) {
            return BuyBackSubmitResult.fail("num <= 0");
        }

        // 1. 装载配置
        Map<Integer, ShuishouConfigmap> confMap =
                ConfigManager.getInstance().getConf(ShuishouConfigmap.class);
        if (confMap == null || confMap.isEmpty()) {
            return BuyBackSubmitResult.fail("config map empty");
        }

        ShuishouConfigmap conf = null;
        for (ShuishouConfigmap c : confMap.values()) {
            if (c.getType() == cmd.itemType && c.getItmeid() == cmd.itemId) {
                conf = c;
                break;
            }
        }

        if (conf == null) {
            return BuyBackSubmitResult.fail("config not found");
        }
        if (conf.getEnable() != 1) {
            return BuyBackSubmitResult.fail("config disabled");
        }

        // 2. 时间窗口校验
        String startTimeStr = conf.getStartTime();
        String endTimeStr = conf.getEndTime();
        long now = System.currentTimeMillis();
        if (startTimeStr != null && endTimeStr != null
                && !startTimeStr.isEmpty() && !endTimeStr.isEmpty()) {
            long start = parseDateAsDayMillis(startTimeStr);
            long end = parseDateAsDayMillis(endTimeStr);
            if (start > 0 && end > 0 && (now < start || now > end)) {
                return BuyBackSubmitResult.fail("out of time window");
            }
        }

        // 3. 计算当日剩余额度
        long todayStart = getTodayStartTimestamp();
        String todayKey = String.valueOf(todayStart + (long) conf.getItmeid());
        RoleTradingRecord dayRecord = Roletradingrecordstab.get(todayKey);
        int used = dayRecord != null ? dayRecord.getAllnum() : 0;
        int dailyMax = conf.getMax();
        int remainDaily = dailyMax - used;
        if (remainDaily <= 0) {
            return BuyBackSubmitResult.fail("daily quota exhausted");
        }

        int allowedNum = Math.min(remainDaily, cmd.num);
        if (allowedNum <= 0) {
            return BuyBackSubmitResult.fail("num not allowed");
        }

        // 4. 检查背包数量
        Pack pack = new Pack(cmd.roleId, false);
        int owned = pack.getBagItemNum(conf.getItmeid());
        if (owned < allowedNum) {
            return BuyBackSubmitResult.fail("not enough items in bag");
        }

        // 5. 金额与溢出保护
        long totalPrice = (long) conf.getMoneynum() * allowedNum;
        if (totalPrice <= 0L || totalPrice > Integer.MAX_VALUE) {
            return BuyBackSubmitResult.fail("price overflow");
        }

        // 6. 扣除物品
        int removed = pack.removeItemById(conf.getItmeid(), allowedNum,
                YYLoggerTuJingEnum.tujing_Value_worldchat, 0, "回购扣除");
        if (removed != allowedNum) {
            return BuyBackSubmitResult.fail("remove items mismatch");
        }

        // 7. 发放货币/符石
        int moneyType = conf.getMoneytype();
        boolean addOk;
        if (moneyType != 3) { // 3=符石, 其他为货币
            long before = pack.getCurrency(moneyType);
            long after = pack.addSysCurrency(totalPrice, moneyType,
                    "回购获得", YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
            addOk = (after - before) == totalPrice;
        } else {
            PropRole propRole = new PropRole(cmd.roleId, true);
            int userId = propRole.getUserid();
            addOk = new PAddFuShi(userId, cmd.roleId, (int) totalPrice,
                    0, YYLoggerTuJingEnum.tujing_Value_mailget).call();
        }

        if (!addOk) {
            logger.error("BuyBack add currency failed, roleId=" + cmd.roleId
                    + ", itemId=" + conf.getItmeid()
                    + ", totalPrice=" + totalPrice);
            MessageMgr.sendMsgNotify(cmd.roleId, 201070, null);
            return BuyBackSubmitResult.fail("add currency failed");
        }

        // 8. 更新当日记录
        if (dayRecord == null) {
            dayRecord = Pod.newRoleTradingRecord();
            Roletradingrecordstab.insert(todayKey, dayRecord);
        }
        dayRecord.setTradingid(todayKey);
        dayRecord.setRoleid(cmd.roleId);
        dayRecord.setTradingtype(conf.getItmeid());
        dayRecord.setCurnum(allowedNum);
        dayRecord.setAllnum(dayRecord.getAllnum() + allowedNum);
        dayRecord.setPrice(conf.getMoneynum());
        dayRecord.setCreatetime(now);
        dayRecord.setTradingtime(0L);
        dayRecord.setState(0);

        // 9. 更新历史记录
        RoleTradingHisRecordList hisList = Roletradinghisrecordlisttab.get(cmd.roleId);
        if (hisList == null) {
            hisList = Pod.newRoleTradingHisRecordList();
            Roletradinghisrecordlisttab.insert(cmd.roleId, hisList);
        }
        List<RoleTradingHisRecord> hisRecords = hisList.getRoletradinghisrecordlist();
        if (hisRecords.size() >= HISTORY_MAX_COUNT) {
            hisRecords.remove(0);
        }

        RoleTradingHisRecord his = createRoleTradingHisRecord(
                todayKey, conf.getItmeid(), allowedNum,
                conf.getMoneytype(), conf.getMoneynum(), now);
        hisRecords.add(his);

        int remainInBag = pack.getBagItemNum(conf.getItmeid());
        int newRemainDaily = remainDaily - allowedNum;

        MessageMgr.sendMsgNotify(cmd.roleId, 201069, null); // 通知玩家获得提示

        return BuyBackSubmitResult.ok(remainInBag, newRemainDaily);
    }

    /** 创建历史记录(供本模块与其它业务复用) */
    public static RoleTradingHisRecord createRoleTradingHisRecord(String tradingId,
                                                                  int tradingType,
                                                                  int curNum,
                                                                  int allNum,
                                                                  int price,
                                                                  long time) {
        RoleTradingHisRecord record = Pod.newRoleTradingHisRecord();
        record.setTradingid(tradingId);
        record.setTradingtype(tradingType);
        record.setCurnum(curNum);
        record.setAllnum(allNum);
        record.setPrice(price);
        record.setCreatetime(time);
        record.setTradingtime(System.currentTimeMillis());
        return record;
    }

    private static BuyBackListResult queryConfigList(BuyBackQuery query) {
        Map<Integer, ShuishouConfigmap> confMap =
                ConfigManager.getInstance().getConf(ShuishouConfigmap.class);
        if (confMap == null || confMap.isEmpty()) {
            return new BuyBackListResult(
                    query.findType, query.itemType, query.isTimeLimit,
                    query.page, query.pageSize, 0, new ArrayList<ItemBuyBackOs>(0)
            );
        }

        List<ItemBuyBackOs> allItems = new ArrayList<ItemBuyBackOs>();

        long todayStart = getTodayStartTimestamp();
        for (ShuishouConfigmap conf : confMap.values()) {
            if (conf.getType() != query.itemType) {
                continue;
            }
            // 修复：根据请求的 isTimeLimit 参数过滤
            // isTimeLimit=1 -> 显示限时物品 (enable=1)
            // isTimeLimit=0 -> 显示普通物品 (enable=0)
            if (conf.getEnable() != query.isTimeLimit) {
                continue;
            }

            int dailyMax = conf.getMax();
            if (dailyMax <= 0) {
                continue;
            }

            String todayKey = String.valueOf(todayStart + (long) conf.getItmeid());
            RoleTradingRecord dayRecord = Roletradingrecordstab.get(todayKey);
            int used = dayRecord != null ? dayRecord.getAllnum() : 0;
            int remain = dailyMax - used;
            if (remain <= 0) {
                continue;
            }

            ItemBuyBackOs os = new ItemBuyBackOs(
                    conf.getId(),
                    conf.getType(),
                    conf.getEnable(),
                    0,
                    conf.getItmeid(),
                    conf.getItemname(),
                    conf.getMoneynum(),
                    remain,
                    conf.getMoneytype(),
                    conf.getStartTime(),
                    conf.getEndTime()
            );
            allItems.add(os);
        }

        int total = allItems.size();
        if (total == 0) {
            return new BuyBackListResult(
                    query.findType, query.itemType, query.isTimeLimit,
                    query.page, query.pageSize, 0, allItems
            );
        }

        int fromIndex = (query.page - 1) * query.pageSize;
        if (fromIndex >= total) {
            fromIndex = 0;
        }
        int toIndex = Math.min(fromIndex + query.pageSize, total);
        List<ItemBuyBackOs> pageItems = allItems.subList(fromIndex, toIndex);

        int pageTotal = (int) Math.ceil((double) total / (double) query.pageSize);
        return new BuyBackListResult(
                query.findType, query.itemType, query.isTimeLimit,
                query.page, query.pageSize, pageTotal,
                new ArrayList<ItemBuyBackOs>(pageItems)
        );
    }

    private static BuyBackListResult queryHistoryList(BuyBackQuery query) {
        RoleTradingHisRecordList list = Roletradinghisrecordlisttab.select(query.roleId);
        if (list == null) {
            return new BuyBackListResult(
                    query.findType, query.itemType, query.isTimeLimit,
                    query.page, query.pageSize, 0, new ArrayList<ItemBuyBackOs>(0)
            );
        }

        List<RoleTradingHisRecord> data = list.getRoletradinghisrecordlistAsData();
        if (data.isEmpty()) {
            return new BuyBackListResult(
                    query.findType, query.itemType, query.isTimeLimit,
                    query.page, query.pageSize, 0, new ArrayList<ItemBuyBackOs>(0)
            );
        }

        // 与现有实现保持一致：按 tradingtime 降序排序
        Collections.sort(data, new fire.pb.fushi.spotcheck.RoleTradingHisRecordComparator());

        int total = data.size();
        int fromIndex = (query.page - 1) * query.pageSize;
        if (fromIndex >= total) {
            fromIndex = 0;
        }
        int toIndex = Math.min(fromIndex + query.pageSize, total);

        List<ItemBuyBackOs> items = new ArrayList<ItemBuyBackOs>();
        for (int i = fromIndex; i < toIndex; i++) {
            RoleTradingHisRecord r = data.get(i);
            ItemBuyBackOs os = new ItemBuyBackOs(
                    i,                       // ID
                    0,                       // itemtype (历史记录不区分)
                    0,                       // 时限
                    0,                       // 时间限制
                    r.getTradingtype(),      // 这里兼容旧逻辑：使用 tradingtype
                    "",                      // itemname 在客户端自行解析/忽略
                    r.getPrice(),
                    r.getCurnum(),
                    r.getAllnum(),
                    String.valueOf(r.getCreatetime()),
                    ""                       // endtime 占位
            );
            items.add(os);
        }

        int pageTotal = (int) Math.ceil((double) total / (double) query.pageSize);
        return new BuyBackListResult(
                query.findType, query.itemType, query.isTimeLimit,
                query.page, query.pageSize, pageTotal, items
        );
    }

    /** 取当日00:00:00.000的时间戳 */
    public static long getTodayStartTimestamp() {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, 0);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        c.set(Calendar.MILLISECOND, 0);
        return c.getTimeInMillis();
    }

    /*将yyyy-MM-dd或yyyy-MM-dd HH:mm:ss格式解析为某天起始时间戳, 失败返回-1 */
    private static long parseDateAsDayMillis(String s) {
        if (s == null || s.isEmpty()) {
            return -1L;
        }
        // 简单拆分：支持 "yyyy-MM-dd" 或 "yyyy/MM/dd" 或 "yyyy.MM.dd"
        String normalized = s.trim().replace('/', '-').replace('.', '-');
        String[] parts = normalized.split("-");
        if (parts.length < 3) {
            return -1L;
        }
        try {
            int year = Integer.parseInt(parts[0]);
            int month = Integer.parseInt(parts[1]);
            int day = Integer.parseInt(parts[2]);
            Calendar c = Calendar.getInstance();
            c.set(Calendar.YEAR, year);
            c.set(Calendar.MONTH, month - 1);
            c.set(Calendar.DAY_OF_MONTH, day);
            c.set(Calendar.HOUR_OF_DAY, 0);
            c.set(Calendar.MINUTE, 0);
            c.set(Calendar.SECOND, 0);
            c.set(Calendar.MILLISECOND, 0);
            return c.getTimeInMillis();
        } catch (NumberFormatException e) {
            logger.warn("parseDateAsDayMillis failed for string: " + s, e);
            return -1L;
        }
    }

    /** 协议入口统一封装: 根据roleId立即执行一次回购提交(方便GM或其它模块复用) */
    public static BuyBackSubmitResult submitImmediately(final BuyBackCommand cmd) {
        final BuyBackSubmitResult[] holder = new BuyBackSubmitResult[1];
        new Procedure() {
            @Override
            protected boolean process() throws Exception {
                holder[0] = BuyBackService.submit(cmd);
                if (!holder[0].success) {
                    logger.warn("BuyBack submit failed, roleId=" + cmd.roleId
                            + ", itemId=" + cmd.itemId + ", msg=" + holder[0].message);
                }
                return holder[0].success;
            }
        }.call();
        return holder[0] != null ? holder[0] : BuyBackSubmitResult.fail("unknown error");
    }
}

