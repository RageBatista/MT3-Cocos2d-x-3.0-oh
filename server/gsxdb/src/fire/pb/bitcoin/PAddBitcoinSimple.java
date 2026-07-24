package fire.pb.bitcoin;

import fire.log.enums.YYLoggerTuJingEnum;
import mkdb.Procedure;
import org.apache.log4j.Logger;

/**
 * 比特币添加处理类 (Pack系统集成)
 * 类似于 PAddFuShi，处理比特币的添加操作
 * 专门用于 Pack.addSysCurrency 中的比特币特殊处理
 *
 * 使用场景：
 * - GM指令添加比特币
 * - 系统奖励比特币
 * - 其他通过Pack系统的比特币操作
 */
public class PAddBitcoinSimple extends Procedure {

    private static final Logger logger = Logger.getLogger("BITCOIN");

    private final int userId;
    private final long roleId;
    private final int bitcoinNum;
    private final int bitcoinType;
    private final YYLoggerTuJingEnum way;

    /**
     * 构造函数
     * @param userId 用户ID
     * @param roleId 角色ID
     * @param bitcoinNum 比特币数量
     * @param bitcoinType 比特币类型(BitcoinConst.CASH_BITCOIN 或 BitcoinConst.SYS_BITCOIN)
     * @param way 操作途径
     */
    public PAddBitcoinSimple(int userId, long roleId, int bitcoinNum, int bitcoinType, YYLoggerTuJingEnum way) {
        this.userId = userId;
        this.roleId = roleId;
        this.bitcoinNum = bitcoinNum;
        this.bitcoinType = bitcoinType;
        this.way = way;
    }

    @Override
    protected boolean process() throws Exception {
        try {
            // 参数验证
            if (userId <= 0 || roleId <= 0) {
                logger.error("PAddBitcoinSimple: 无效的用户ID或角色ID - userId=" + userId + ", roleId=" + roleId);
                return false;
            }

            if (bitcoinNum == 0) {
                logger.warn("PAddBitcoinSimple: 比特币数量为0，跳过处理 - roleId=" + roleId);
                return true;
            }

            // 调用 BitcoinManager 处理比特币操作
            boolean success = BitcoinManager.addBitcoinToUser(userId, roleId, bitcoinNum, bitcoinType, way.name());

            // 统一的日志格式
            String operation = bitcoinNum > 0 ? "添加" : "扣除";
            String typeStr = (bitcoinType == BitcoinConst.SYS_BITCOIN) ? "系统" : "现金";

            if (success) {
                logger.info(String.format("PAddBitcoinSimple: %s%s比特币成功 - User[%d]Role[%d] %s%d",
                    operation, typeStr, userId, roleId, operation, Math.abs(bitcoinNum)));
            } else {
                logger.error(String.format("PAddBitcoinSimple: %s%s比特币失败 - User[%d]Role[%d] %s%d",
                    operation, typeStr, userId, roleId, operation, Math.abs(bitcoinNum)));
            }

            return success;

        } catch (Exception e) {
            logger.error("PAddBitcoinSimple: 处理过程中发生异常 - User[" + userId + "]Role[" + roleId + "] " +
                        "Amount[" + bitcoinNum + "]Type[" + bitcoinType + "]", e);
            return false;
        }
    }

    /**
     * 便捷方法：添加系统比特币
     */
    public static PAddBitcoinSimple createSysBitcoin(int userId, long roleId, int amount, YYLoggerTuJingEnum way) {
        return new PAddBitcoinSimple(userId, roleId, amount, BitcoinConst.SYS_BITCOIN, way);
    }

    /**
     * 便捷方法：添加现金比特币
     */
    public static PAddBitcoinSimple createCashBitcoin(int userId, long roleId, int amount, YYLoggerTuJingEnum way) {
        return new PAddBitcoinSimple(userId, roleId, amount, BitcoinConst.CASH_BITCOIN, way);
    }
}
