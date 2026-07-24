package fire.pb.bitcoin;

import fire.log.enums.YYLoggerTuJingEnum;
import org.apache.log4j.Logger;
import xbean.BitcoinNum;
import xbean.BitcoinNums;
import xbean.Pod;
import xtable.Bitcoinnum;

/**
 * 比特币管理器
 * 类似于 FushiManager，提供完整的比特币管理功能
 * 支持现金比特币和系统比特币两种类型
 *
 * 架构说明：
 * - 现金比特币：充值或购买获得，可交易
 * - 系统比特币：系统赠送，优先消费
 * - 数据存储：xtable.Bitcoinnum (BitcoinNums -> BitcoinNum)
 */
public class BitcoinManager {

    public static final Logger logger = Logger.getLogger("BITCOIN");
    public static final Logger warnlogger = Logger.getLogger("BITCOINWARN");

    private static BitcoinManager instance = new BitcoinManager();

    public static BitcoinManager getInstance() {
        return instance;
    }

    /**
     * 添加比特币到用户账户
     * @param userid 用户ID
     * @param roleid 角色ID
     * @param bitcoinNum 比特币数量(可以为负数，表示扣除)
     * @param bitcointype 比特币类型(BitcoinConst.CASH_BITCOIN 或 BitcoinConst.SYS_BITCOIN)
     * @param way 操作途径
     * @return 操作结果
     */
    public static boolean addBitcoinToUser(int userid, long roleid, int bitcoinNum, int bitcointype, String way) {
        // 参数验证
        if (userid <= 0 || roleid <= 0) {
            logger.error("BitcoinManager.addBitcoinToUser: 无效参数 userid=" + userid + ", roleid=" + roleid);
            return false;
        }

        if (bitcoinNum == 0) {
            logger.warn("BitcoinManager.addBitcoinToUser: 比特币数量为0，跳过处理 roleid=" + roleid);
            return true;
        }

        // 如果是扣除操作，调用专门的扣除方法
        if (bitcoinNum < 0) {
            return subBitcoinFromUser(userid, roleid, -bitcoinNum, way);
        }

        try {
            // 获取或创建比特币数据 (类似仙玉系统的 YbNums)
            BitcoinNums bitcoinNums = Bitcoinnum.get(userid);
            if (bitcoinNums == null) {
                bitcoinNums = Pod.newBitcoinNums();
                Bitcoinnum.insert(userid, bitcoinNums);
            }

            // 获取角色比特币数据
            BitcoinNum bitcoinNumBean = bitcoinNums.getRolebitcoin().get(roleid);
            if (bitcoinNumBean == null) {
                bitcoinNumBean = Pod.newBitcoinNum();
                bitcoinNums.getRolebitcoin().put(roleid, bitcoinNumBean);
            }

            // 根据类型添加比特币
            int oldNum = bitcoinNumBean.getNum();
            int oldSysNum = bitcoinNumBean.getSysnum();

            if (bitcointype == BitcoinConst.SYS_BITCOIN) {
                // 系统比特币
                int newSysNum = oldSysNum + bitcoinNum;
                bitcoinNumBean.setSysnum(newSysNum);

                logger.info("添加系统比特币: userid=" + userid + ", roleid=" + roleid +
                           ", amount=" + bitcoinNum + ", old=" + oldSysNum + ", new=" + newSysNum +
                           ", way=" + way);
            } else {
                // 现金比特币
                int newNum = oldNum + bitcoinNum;
                bitcoinNumBean.setNum(newNum);

                logger.info("添加现金比特币: userid=" + userid + ", roleid=" + roleid +
                           ", amount=" + bitcoinNum + ", old=" + oldNum + ", new=" + newNum +
                           ", way=" + way);
            }

            // 更新总比特币数量
            long oldTotal = bitcoinNumBean.getBitcoinall();
            long newTotal = oldTotal + bitcoinNum;
            bitcoinNumBean.setBitcoinall(newTotal);

            // 更新时间戳
            bitcoinNumBean.setTime(System.currentTimeMillis());

            return true;

        } catch (Exception e) {
            logger.error("BitcoinManager.addBitcoinToUser: 发生异常", e);
            return false;
        }
    }

    /**
     * 从用户账户扣除比特币
     * @param userid 用户ID
     * @param roleid 角色ID
     * @param bitcoinNum 比特币数量
     * @param way 操作途径
     * @return 操作结果
     */
    public static boolean subBitcoinFromUser(int userid, long roleid, int bitcoinNum, String way) {
        // 参数验证
        if (userid <= 0 || roleid <= 0 || bitcoinNum <= 0) {
            logger.error("BitcoinManager.subBitcoinFromUser: 无效的比特币数量 bitcoinNum=" + bitcoinNum + ", roleid=" + roleid);
            return false;
        }

        try {
            BitcoinNums bitcoinNums = Bitcoinnum.get(userid);
            if (bitcoinNums == null) {
                logger.error("BitcoinManager.subBitcoinFromUser: 用户 " + userid + " 没有比特币数据");
                return false;
            }

            BitcoinNum bitcoinNumBean = bitcoinNums.getRolebitcoin().get(roleid);
            if (bitcoinNumBean == null) {
                logger.error("BitcoinManager.subBitcoinFromUser: 角色 " + roleid + " 没有比特币数据");
                return false;
            }

            int num = bitcoinNumBean.getNum();
            int sysNum = bitcoinNumBean.getSysnum();

            // 检查比特币是否足够
            if (num + sysNum < bitcoinNum) {
                logger.error("BitcoinManager.subBitcoinFromUser: 比特币不足 userid=" + userid + ", roleid=" + roleid +
                           ", available=" + (num + sysNum) + ", required=" + bitcoinNum);
                return false;
            }

            // 优先扣除系统比特币
            int remainingToDeduct = bitcoinNum;
            int sysDeducted = 0;
            int cashDeducted = 0;

            if (sysNum > 0) {
                sysDeducted = Math.min(sysNum, remainingToDeduct);
                bitcoinNumBean.setSysnum(sysNum - sysDeducted);
                remainingToDeduct -= sysDeducted;
            }

            if (remainingToDeduct > 0) {
                cashDeducted = remainingToDeduct;
                bitcoinNumBean.setNum(num - cashDeducted);
            }

            // 更新时间戳
            bitcoinNumBean.setTime(System.currentTimeMillis());

            logger.info("扣除比特币: userid=" + userid + ", roleid=" + roleid +
                       ", total=" + bitcoinNum + ", cash=" + cashDeducted + ", sys=" + sysDeducted +
                       ", way=" + way);

            return true;

        } catch (Exception e) {
            logger.error("BitcoinManager.subBitcoinFromUser: 发生异常", e);
            return false;
        }
    }

    /**
     * 获取用户比特币余额
     * @param userid 用户ID
     * @param roleid 角色ID
     * @return 比特币余额信息 [现金比特币, 系统比特币]
     */
    public static int[] getBitcoinBalance(int userid, long roleid) {
        try {
            BitcoinNums bitcoinNums = Bitcoinnum.get(userid);
            if (bitcoinNums == null) {
                return new int[]{0, 0};
            }

            BitcoinNum bitcoinNumBean = bitcoinNums.getRolebitcoin().get(roleid);
            if (bitcoinNumBean == null) {
                return new int[]{0, 0};
            }

            return new int[]{bitcoinNumBean.getNum(), bitcoinNumBean.getSysnum()};

        } catch (Exception e) {
            logger.error("BitcoinManager.getBitcoinBalance: 发生异常", e);
            return new int[]{0, 0};
        }
    }

    /**
     * 检查比特币是否足够
     * @param userid 用户ID
     * @param roleid 角色ID
     * @param requiredAmount 需要的数量
     * @return 是否足够
     */
    public static boolean hasSufficientBitcoin(int userid, long roleid, int requiredAmount) {
        int[] balance = getBitcoinBalance(userid, roleid);
        return (balance[0] + balance[1]) >= requiredAmount;
    }
}
