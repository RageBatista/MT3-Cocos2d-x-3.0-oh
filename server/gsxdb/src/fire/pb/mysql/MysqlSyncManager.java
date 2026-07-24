package fire.pb.mysql;

import fire.pb.main.Gs;
import fire.log.Logger;
import xbean.*;
import xtable.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

/**
 * MySQL数据同步管理器
 * 负责将mkdb内存数据库的数据同步到MySQL数据库
 * 
 * @author 服务端技术专家
 * @日期 2025-10-18
 */
public class MysqlSyncManager {
    private static final Logger logger = Logger.getLogger("MysqlSync");
    private static volatile boolean vipinfoTableEnsured = false;
    private static volatile boolean blackMarketTableEnsured = false;

    // MySQL同步配置
    private static final int MAX_RETRY_TIMES = 3;
    private static final long RETRY_DELAY_MS = 1000;

    // 批量操作配置
    private static final int DEFAULT_BATCH_SIZE = 100;
    private static final int MAX_BATCH_SIZE = 500;

    /**
     * 同步统计信息
     */
    public static class SyncStatistics {
        private static final java.util.concurrent.atomic.AtomicLong totalSyncCount = new java.util.concurrent.atomic.AtomicLong(0);
        private static final java.util.concurrent.atomic.AtomicLong successSyncCount = new java.util.concurrent.atomic.AtomicLong(0);
        private static final java.util.concurrent.atomic.AtomicLong failureSyncCount = new java.util.concurrent.atomic.AtomicLong(0);
        private static final java.util.concurrent.atomic.AtomicLong totalSyncTimeMs = new java.util.concurrent.atomic.AtomicLong(0);

        public static void recordSync(boolean success, long timeMs) {
            totalSyncCount.incrementAndGet();
            if (success) {
                successSyncCount.incrementAndGet();
            } else {
                failureSyncCount.incrementAndGet();
            }
            totalSyncTimeMs.addAndGet(timeMs);
        }

        public static String getStatistics() {
            long total = totalSyncCount.get();
            long success = successSyncCount.get();
            long failure = failureSyncCount.get();
            long totalTime = totalSyncTimeMs.get();
            long avgTime = total > 0 ? totalTime / total : 0;

            return String.format(
                "MySQL同步统计 - 总次数: %d, 成功: %d, 失败: %d, 成功率: %.2f%%, 总耗时: %dms, 平均耗时: %dms",
                total, success, failure,
                total > 0 ? (success * 100.0 / total) : 0.0,
                totalTime, avgTime
            );
        }

        public static void reset() {
            totalSyncCount.set(0);
            successSyncCount.set(0);
            failureSyncCount.set(0);
            totalSyncTimeMs.set(0);
        }
    }

    /**
     * 带重试机制的同步操作接口
     */
    private interface SyncOperation {
        boolean execute() throws SQLException;
    }

    /**
     * 执行带重试机制的同步操作
     * @param operation 同步操作
     * @param operationName 操作名称（用于日志）
     * @return 是否成功
     */
    private static boolean executeWithRetry(SyncOperation operation, String operationName) {
        int retryCount = 0;
        long startTime = System.currentTimeMillis();

        while (retryCount <= MAX_RETRY_TIMES) {
            try {
                boolean result = operation.execute();
                long timeMs = System.currentTimeMillis() - startTime;
                SyncStatistics.recordSync(result, timeMs);

                if (result) {
                    if (retryCount > 0) {
                        logger.info(operationName + "成功（重试" + retryCount + "次后）, 耗时: " + timeMs + "ms");
                    } else {
                        logger.info(operationName + "成功, 耗时: " + timeMs + "ms");
                    }
                    return true;
                }
            } catch (SQLException e) {
                retryCount++;
                long timeMs = System.currentTimeMillis() - startTime;

                if (retryCount <= MAX_RETRY_TIMES) {
                    logger.warn(operationName + "失败（第" + retryCount + "次尝试）, 耗时: " + timeMs + "ms, 错误: " + e.getMessage());

                    try {
                        Thread.sleep(RETRY_DELAY_MS);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        logger.error(operationName + "重试等待被中断", ie);
                        return false;
                    }
                } else {
                    logger.error(operationName + "失败（已达最大重试次数）, 总耗时: " + timeMs + "ms", e);
                    SyncStatistics.recordSync(false, timeMs);
                    return false;
                }
            }
        }

        return false;
    }
    
    /**
     * 同步符石数据到MySQL
     * @param userid 用户ID
     */
    public static void syncFushinum(final int userid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    // 检查数据库是否已初始化
                    if (xtable._Tables_.getInstance() == null) {
                        logger.warn("同步符石数据失败: userid=" + userid + ", 数据库未初始化");
                        return;
                    }
                    // 从mkdb获取数据
                    xbean.YbNums ybNums = xtable.Fushinum.select(userid);
                    if (ybNums == null) {
                        logger.warn("同步符石数据失败: userid=" + userid + ", 数据不存在");
                        return;
                    }
                    
                    // 计算总符石数
                    long totalFushi = 0;
                    long totalBindFushi = 0;
                    long totalAllFushi = 0;
                    
                    Map<Long, xbean.YbNum> roleYbMap = ybNums.getRoleyb();
                    if (roleYbMap != null) {
                        for (Map.Entry<Long, xbean.YbNum> entry : roleYbMap.entrySet()) {
                            xbean.YbNum ybNum = entry.getValue();
                            totalFushi += ybNum.getNum();
                            totalBindFushi += ybNum.getSysnum();
                            totalAllFushi += ybNum.getFushiall();
                        }
                    }
                    
                    // 同步到MySQL
                    conn = HikariCPUtil.getConnection();
                    String sql = "INSERT INTO `fushinum`(userid, fushi, bindfushi, totalfushi) " +
                               "VALUES (?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE fushi=?, bindfushi=?, totalfushi=?";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, userid);
                    pstmt.setLong(2, totalFushi);
                    pstmt.setLong(3, totalBindFushi);
                    pstmt.setLong(4, totalAllFushi);
                    pstmt.setLong(5, totalFushi);
                    pstmt.setLong(6, totalBindFushi);
                    pstmt.setLong(7, totalAllFushi);
                    
                    int ret = pstmt.executeUpdate();
                    logger.info("同步符石数据成功: userid=" + userid + ", ret=" + ret);
                    
                } catch (SQLException e) {
                    logger.error("同步符石数据失败: userid=" + userid, e);
                } finally {
                    closeResources(pstmt, conn);
                }
            }
        });
    }
    
    /**
     * 同步比特币数据到MySQL
     * @param userid 用户ID
     */
    public static void syncBitcoinnum(final int userid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    // 检查数据库是否已初始化
                    if (xtable._Tables_.getInstance() == null) {
                        logger.warn("同步比特币数据失败: userid=" + userid + ", 数据库未初始化");
                        return;
                    }
                    // 从mkdb获取数据
                    xbean.BitcoinNums bitcoinNums = xtable.Bitcoinnum.select(userid);
                    if (bitcoinNums == null) {
                        logger.warn("同步比特币数据失败: userid=" + userid + ", 数据不存在");
                        return;
                    }
                    
                    // 计算总比特币数
                    long totalBitcoin = 0;
                    long totalSysBitcoin = 0;
                    long totalAllBitcoin = 0;
                    
                    Map<Long, xbean.BitcoinNum> roleBitcoinMap = bitcoinNums.getRolebitcoin();
                    if (roleBitcoinMap != null) {
                        for (Map.Entry<Long, xbean.BitcoinNum> entry : roleBitcoinMap.entrySet()) {
                            xbean.BitcoinNum bitcoinNum = entry.getValue();
                            totalBitcoin += bitcoinNum.getNum();
                            totalSysBitcoin += bitcoinNum.getSysnum();
                            totalAllBitcoin += bitcoinNum.getBitcoinall();
                        }
                    }
                    
                    // 同步到MySQL
                    conn = HikariCPUtil.getConnection();
                    String sql = "INSERT INTO `bitcoinnum`(roleid, bitcoin, sysbitcoin, totalbitcoin) " +
                               "VALUES (?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE bitcoin=?, sysbitcoin=?, totalbitcoin=?";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, userid);
                    pstmt.setLong(2, totalBitcoin);
                    pstmt.setLong(3, totalSysBitcoin);
                    pstmt.setLong(4, totalAllBitcoin);
                    pstmt.setLong(5, totalBitcoin);
                    pstmt.setLong(6, totalSysBitcoin);
                    pstmt.setLong(7, totalAllBitcoin);
                    
                    int ret = pstmt.executeUpdate();
                    logger.info("同步比特币数据成功: userid=" + userid + ", ret=" + ret);
                    
                } catch (SQLException e) {
                    logger.error("同步比特币数据失败: userid=" + userid, e);
                } finally {
                    closeResources(pstmt, conn);
                }
            }
        });
    }
    
    /**
     * 同步VIP信息到MySQL
     * @param roleid 角色ID
     */
    public static void syncVipinfo(final long roleid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    // 检查数据库是否已初始化
                    if (xtable._Tables_.getInstance() == null) {
                        logger.warn("同步VIP信息失败: roleid=" + roleid + ", 数据库未初始化");
                        return;
                    }
                    // 从mkdb获取数据
                    xbean.Vipinfo vipinfo = xtable.Vipinfo.select(roleid);
                    if (vipinfo == null) {
                        logger.warn("同步VIP信息失败: roleid=" + roleid + ", 数据不存在");
                        return;
                    }
                    
                    // 同步到MySQL
                    conn = HikariCPUtil.getConnection();
                    ensureVipinfoTable(conn);
                    String sql = "INSERT INTO `vipinfo`(roleid, vipexp, viplevel, bonus, gotbonus) " +
                               "VALUES (?, ?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE vipexp=?, viplevel=?, bonus=?, gotbonus=?";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setLong(1, roleid);
                    pstmt.setInt(2, vipinfo.getVipexp());
                    pstmt.setInt(3, vipinfo.getViplevel());
                    pstmt.setInt(4, vipinfo.getBonus());
                    pstmt.setInt(5, vipinfo.getGotbonus());
                    pstmt.setInt(6, vipinfo.getVipexp());
                    pstmt.setInt(7, vipinfo.getViplevel());
                    pstmt.setInt(8, vipinfo.getBonus());
                    pstmt.setInt(9, vipinfo.getGotbonus());
                    
                    int ret = pstmt.executeUpdate();
                    logger.info("同步VIP信息成功: roleid=" + roleid + ", ret=" + ret);
                    
                } catch (SQLException e) {
                    logger.error("同步VIP信息失败: roleid=" + roleid, e);
                } finally {
                    closeResources(pstmt, conn);
                }
            }
        });
    }
    
    /**
     * 同步每日充值数据到MySQL
     * @param userid 用户ID
     */
    public static void syncRoledaypay(final int userid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    // 检查数据库是否已初始化
                    if (xtable._Tables_.getInstance() == null) {
                        logger.warn("同步每日充值数据失败: userid=" + userid + ", 数据库未初始化");
                        return;
                    }
                    // 从mkdb获取数据
                    xbean.EDayPay eDayPay = xtable.Roledaypay.select(userid);
                    if (eDayPay == null) {
                        logger.warn("同步每日充值数据失败: userid=" + userid + ", 数据不存在");
                        return;
                    }
                    
                    Map<Long, xbean.DayPay> roleid2daypay = eDayPay.getRoleid2daypay();
                    if (roleid2daypay == null || roleid2daypay.isEmpty()) {
                        logger.warn("同步每日充值数据失败: userid=" + userid + ", 无充值记录");
                        return;
                    }

                    conn = HikariCPUtil.getConnection();
                    String sql = "INSERT INTO `roledaypay`(roleid, userid, expiretime, firstprompt) " +
                               "VALUES (?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE expiretime=?, firstprompt=?";

                    pstmt = conn.prepareStatement(sql);

                    int syncCount = 0;
                    for (Map.Entry<Long, xbean.DayPay> entry : roleid2daypay.entrySet()) {
                        long roleid = entry.getKey();
                        xbean.DayPay dayPay = entry.getValue();
                        
                        pstmt.setLong(1, roleid);
                        pstmt.setInt(2, userid);
                        pstmt.setLong(3, dayPay.getExpiretime());
                        pstmt.setInt(4, dayPay.getFirstprompt());
                        pstmt.setLong(5, dayPay.getExpiretime());
                        pstmt.setInt(6, dayPay.getFirstprompt());
                        
                        pstmt.addBatch();
                        syncCount++;
                    }
                    
                    int[] rets = pstmt.executeBatch();
                    logger.info("同步每日充值数据成功: userid=" + userid + ", 同步了" + syncCount + "条记录");
                    
                } catch (SQLException e) {
                    logger.error("同步每日充值数据失败: userid=" + userid, e);
                } finally {
                    closeResources(pstmt, conn);
                }
            }
        });
    }
    
    /**
     * 同步封禁记录到MySQL
     * @param userid 用户ID
     */
    public static void syncUserpunish(final int userid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                Connection conn = null;
                PreparedStatement pstmt1 = null;
                PreparedStatement pstmt2 = null;
                try {
                    // 检查数据库是否已初始化
                    if (xtable._Tables_.getInstance() == null) {
                        logger.warn("同步封禁记录失败: userid=" + userid + ", 数据库未初始化");
                        return;
                    }
                    // 从mkdb获取数据
                    xbean.UserPunish userPunish = xtable.Userpunish.select(userid);
                    if (userPunish == null) {
                        logger.warn("同步封禁记录失败: userid=" + userid + ", 数据不存在");
                        return;
                    }
                    
                    conn = HikariCPUtil.getConnection();
                    
                    // 同步userpunish表
                    String sql1 = "INSERT INTO `userpunish`(userid, releasetime, waiguatimes, sendmsgtime) " +
                                "VALUES (?, ?, ?, ?) " +
                                "ON DUPLICATE KEY UPDATE releasetime=?, waiguatimes=?, sendmsgtime=?";
                    
                    pstmt1 = conn.prepareStatement(sql1);
                    pstmt1.setInt(1, userid);
                    pstmt1.setLong(2, userPunish.getReleasetime());
                    pstmt1.setInt(3, userPunish.getWaiguatimes());
                    pstmt1.setLong(4, userPunish.getSendmsgtime());
                    pstmt1.setLong(5, userPunish.getReleasetime());
                    pstmt1.setInt(6, userPunish.getWaiguatimes());
                    pstmt1.setLong(7, userPunish.getSendmsgtime());
                    
                    int ret1 = pstmt1.executeUpdate();
                    logger.info("同步封禁记录成功: userid=" + userid + ", ret=" + ret1);
                    
                    // 同步punishrecord表
                    if (userPunish.getRecords() != null && !userPunish.getRecords().isEmpty()) {
                        String sql2 = "INSERT INTO `punishrecord`(userid, roleid, type, forbidtime, gmuserid, optime, reason) " +
                                    "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                                    "ON DUPLICATE KEY UPDATE forbidtime=?, optime=?, reason=?";
                        
                        pstmt2 = conn.prepareStatement(sql2);

                        for (xbean.PunishRecord record : userPunish.getRecords()) {
                            pstmt2.setInt(1, record.getUserid());
                            pstmt2.setLong(2, record.getRoleid());
                            pstmt2.setInt(3, record.getType());
                            pstmt2.setLong(4, record.getForbidtime());
                            pstmt2.setInt(5, record.getGmuserid());
                            pstmt2.setLong(6, record.getOptime());
                            pstmt2.setString(7, record.getReason());
                            pstmt2.setLong(8, record.getForbidtime());
                            pstmt2.setLong(9, record.getOptime());
                            pstmt2.setString(10, record.getReason());
                            
                            pstmt2.addBatch();
                        }
                        
                        int[] rets = pstmt2.executeBatch();
                        logger.info("同步封禁详细记录成功: userid=" + userid + ", 同步了" + rets.length + "条记录");
                    }
                    
                } catch (SQLException e) {
                    logger.error("同步封禁记录失败: userid=" + userid, e);
                } finally {
                    if (pstmt2 != null) {
                        try {
                            pstmt2.close();
                        } catch (SQLException e) {
                            logger.error("关闭PreparedStatement失败", e);
                        }
                    }
                    closeResources(pstmt1, conn);
                }
            }
        });
    }
    
    /**
     * 同步黑市数据到MySQL（带重试机制）
     * @param roleid 角色ID
     */
    public static void syncBlackMarket(final long roleid) {
        Gs.getExecService().execute(new Runnable() {
            @Override
            public void run() {
                executeWithRetry(new SyncOperation() {
                    @Override
                    public boolean execute() throws SQLException {
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        try {
                            // 检查数据库是否已初始化
                            if (xtable._Tables_.getInstance() == null) {
                                logger.warn("同步黑市数据失败: roleid=" + roleid + ", 数据库未初始化");
                                return false;
                            }
                            // 从mkdb获取数据
                            xbean.RoleBlackMarket blackMarket = xtable.Blackmarkettab.select(roleid);
                            if (blackMarket == null) {
                                logger.warn("同步黑市数据失败: roleid=" + roleid + ", 数据不存在");
                                return false;
                            }

                            // 同步到MySQL
                            conn = HikariCPUtil.getConnection();
                            ensureBlackMarketTable(conn);

                            // 统计订单数据
                            int goldOrderSaleCount = 0;
                            int goldOrderBuyCount = 0;
                            long goldOrderSaleTotal = 0;
                            long goldOrderBuyTotal = 0;
                            long updateTime = System.currentTimeMillis();

                            // 统计金币售卖订单
                            java.util.Map<Long, xbean.GoldOrder> goldOrderSaleMap = blackMarket.getGoldordersale();
                            if (goldOrderSaleMap != null) {
                                for (java.util.Map.Entry<Long, xbean.GoldOrder> entry : goldOrderSaleMap.entrySet()) {
                                    xbean.GoldOrder order = entry.getValue();
                                    if (order.getState() == fire.pb.blackmarket.utils.BlackMarketUtils.OrderState.STAY_SALE) {
                                        goldOrderSaleCount++;
                                        goldOrderSaleTotal += order.getNumber();
                                    }
                                }
                            }

                            // 统计金币购买订单
                            java.util.Map<Long, xbean.GoldOrder> goldOrderBuyMap = blackMarket.getGoldorderbuy();
                            if (goldOrderBuyMap != null) {
                                for (java.util.Map.Entry<Long, xbean.GoldOrder> entry : goldOrderBuyMap.entrySet()) {
                                    xbean.GoldOrder order = entry.getValue();
                                    if (order.getState() == fire.pb.blackmarket.utils.BlackMarketUtils.OrderState.STAY_TAKE) {
                                        goldOrderBuyCount++;
                                        goldOrderBuyTotal += order.getNumber();
                                    }
                                }
                            }

                            String sql = "INSERT INTO `blackmarket`(roleid, goldorder_sale_count, goldorder_buy_count, goldorder_sale_total, goldorder_buy_total, updatetime) " +
                                       "VALUES (?, ?, ?, ?, ?, ?) " +
                                       "ON DUPLICATE KEY UPDATE goldorder_sale_count=?, goldorder_buy_count=?, goldorder_sale_total=?, goldorder_buy_total=?, updatetime=?";

                            pstmt = conn.prepareStatement(sql);
                            pstmt.setLong(1, roleid);
                            pstmt.setInt(2, goldOrderSaleCount);
                            pstmt.setInt(3, goldOrderBuyCount);
                            pstmt.setLong(4, goldOrderSaleTotal);
                            pstmt.setLong(5, goldOrderBuyTotal);
                            pstmt.setLong(6, updateTime);
                            pstmt.setInt(7, goldOrderSaleCount);
                            pstmt.setInt(8, goldOrderBuyCount);
                            pstmt.setLong(9, goldOrderSaleTotal);
                            pstmt.setLong(10, goldOrderBuyTotal);
                            pstmt.setLong(11, updateTime);

                            int ret = pstmt.executeUpdate();
                            logger.info("同步黑市数据成功: roleid=" + roleid + ", ret=" + ret);
                            return ret > 0;

                        } finally {
                            closeResources(pstmt, conn);
                        }
                    }
                }, "同步黑市数据[roleid=" + roleid + "]");
            }
        });
    }

    /**
     * 获取MySQL同步统计信息
     * @return 统计信息字符串
     */
    public static String getSyncStatistics() {
        return SyncStatistics.getStatistics();
    }

    /**
     * 重置MySQL同步统计信息
     */
    public static void resetSyncStatistics() {
        SyncStatistics.reset();
        logger.info("MySQL同步统计信息已重置");
    }

    /**
     * 获取MySQL同步健康状态
     * @return 健康状态信息
     */
    public static String getHealthStatus() {
        StringBuilder status = new StringBuilder();
        status.append("=== MySQL同步健康状态 ===\n");

        // 连接池状态
        status.append("连接池状态:\n");
        status.append(HikariCPUtil.getDetailedPoolStatus()).append("\n");

        // 健康检查
        boolean healthOk = HikariCPUtil.performHealthCheck();
        status.append("健康检查: ").append(healthOk ? "正常" : "异常").append("\n");

        // 同步统计
        status.append("\n").append(SyncStatistics.getStatistics()).append("\n");

        // 表初始化状态
        status.append("\n表初始化状态:\n");
        status.append("  vipinfo表: ").append(vipinfoTableEnsured ? "已初始化" : "未初始化").append("\n");
        status.append("  blackmarket表: ").append(blackMarketTableEnsured ? "已初始化" : "未初始化").append("\n");

        return status.toString();
    }

    /**
     * 关闭资源
     */
    private static void closeResources(PreparedStatement pstmt, Connection conn) {
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) {
                logger.error("关闭PreparedStatement失败", e);
            }
        }
        if (conn != null) {
            HikariCPUtil.close(conn, null, null);
        }
    }
    
    /**
     * 确保 vipinfo 表存在
     */
    private static void ensureVipinfoTable(Connection conn) throws SQLException {
        if (vipinfoTableEnsured)
            return;
        synchronized (MysqlSyncManager.class) {
            if (vipinfoTableEnsured)
                return;
            PreparedStatement stmt = null;
            try {
                String ddl = "CREATE TABLE IF NOT EXISTS `vipinfo`("
                        + "`roleid` BIGINT NOT NULL,"
                        + "`vipexp` INT NOT NULL DEFAULT 0,"
                        + "`viplevel` INT NOT NULL DEFAULT 0,"
                        + "`bonus` INT NOT NULL DEFAULT 0,"
                        + "`gotbonus` INT NOT NULL DEFAULT 0,"
                        + "PRIMARY KEY (`roleid`)"
                        + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
                stmt = conn.prepareStatement(ddl);
                stmt.executeUpdate();
                vipinfoTableEnsured = true;
            } finally {
                if (stmt != null) {
                    try {
                        stmt.close();
                    } catch (SQLException e) {
                        logger.error("关闭PreparedStatement失败", e);
                    }
                }
            }
        }
    }

    /**
     * 确保 blackmarket 表存在
     */
    private static void ensureBlackMarketTable(Connection conn) throws SQLException {
        if (blackMarketTableEnsured)
            return;
        synchronized (MysqlSyncManager.class) {
            if (blackMarketTableEnsured)
                return;
            PreparedStatement stmt = null;
            try {
                String ddl = "CREATE TABLE IF NOT EXISTS `blackmarket`("
                        + "`roleid` BIGINT NOT NULL,"
                        + "`goldorder_sale_count` INT NOT NULL DEFAULT 0,"
                        + "`goldorder_buy_count` INT NOT NULL DEFAULT 0,"
                        + "`goldorder_sale_total` BIGINT NOT NULL DEFAULT 0,"
                        + "`goldorder_buy_total` BIGINT NOT NULL DEFAULT 0,"
                        + "`updatetime` BIGINT NOT NULL DEFAULT 0,"
                        + "PRIMARY KEY (`roleid`)"
                        + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
                stmt = conn.prepareStatement(ddl);
                stmt.executeUpdate();
                blackMarketTableEnsured = true;
            } finally {
                if (stmt != null) {
                    try {
                        stmt.close();
                    } catch (SQLException e) {
                        logger.error("关闭PreparedStatement失败", e);
                    }
                }
            }
        }
    }

    /**
     * 批量操作辅助类
     * 用于分批处理大量数据，避免单次操作数据量过大
     */
    public static class BatchHelper {
        /**
         * 分批执行操作
         * @param <T> 数据类型
         * @param dataList 数据列表
         * @param batchSize 每批大小
         * @param processor 批处理器
         * @return 总处理数量
         */
        public static <T> int processBatch(java.util.List<T> dataList, int batchSize, BatchProcessor<T> processor) throws SQLException {
            if (dataList == null || dataList.isEmpty()) {
                return 0;
            }

            // 确保批次大小在合理范围内
            batchSize = Math.min(batchSize, MAX_BATCH_SIZE);
            batchSize = Math.max(batchSize, 1);

            int totalCount = 0;
            int totalBatches = (dataList.size() + batchSize - 1) / batchSize;

            for (int i = 0; i < totalBatches; i++) {
                int fromIndex = i * batchSize;
                int toIndex = Math.min(fromIndex + batchSize, dataList.size());
                java.util.List<T> batch = dataList.subList(fromIndex, toIndex);

                boolean success = executeWithRetry(new SyncOperation() {
                    @Override
                    public boolean execute() throws SQLException {
                        return processor.process(batch);
                    }
                }, "批量处理[batch=" + (i + 1) + "/" + totalBatches + ", size=" + batch.size() + "]");

                if (success) {
                    totalCount += batch.size();
                } else {
                    logger.warn("批量处理失败，跳过批次: " + (i + 1) + "/" + totalBatches);
                }
            }

            return totalCount;
        }

        /**
         * 批处理器接口
         * @param <T> 数据类型
         */
        public interface BatchProcessor<T> {
            boolean process(java.util.List<T> batch) throws SQLException;
        }
    }

    /**
     * 获取默认批量大小
     * @return 默认批量大小
     */
    public static int getDefaultBatchSize() {
        return DEFAULT_BATCH_SIZE;
    }

    /**
     * 获取最大批量大小
     * @return 最大批量大小
     */
    public static int getMaxBatchSize() {
        return MAX_BATCH_SIZE;
    }
}

