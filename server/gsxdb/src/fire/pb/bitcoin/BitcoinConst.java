package fire.pb.bitcoin;

/**
 * 比特币系统常量定义
 * 类似于 FushiConst，定义比特币相关的常量
 */
public class BitcoinConst {

    // 比特币类型常量
    public static final int CASH_BITCOIN = 0;    // 现金比特币(充值或购买获得)
    public static final int SYS_BITCOIN = 1;     // 系统比特币(系统赠送)

    // 比特币操作原因常量
    public static final int REASON_ADD_BITCOIN_WANFA = 1001;     // 添加比特币玩法
    public static final int REASON_BUY_DAYPAY = 1002;            // 购买日付费
    public static final int REASON_GM_ADD = 1003;                // GM添加
    public static final int REASON_EXCHANGE = 1004;              // 兑换获得
    public static final int REASON_SYSTEM_REWARD = 1005;         // 系统奖励
    public static final int REASON_ACTIVITY_REWARD = 1006;       // 活动奖励
    public static final int REASON_CONSUME_ITEM = 2001;          // 消费物品
    public static final int REASON_CONSUME_SERVICE = 2002;       // 消费服务
    public static final int REASON_EXCHANGE_CURRENCY = 2003;     // 兑换其他货币

    // 系统角色ID (用于系统操作)
    public static final long SYS_BITCOIN_ROLEID = 100L;

    // 比特币数量限制
    public static final int MAX_BITCOIN_NUM = 1999999999;        // 最大比特币数量
    public static final int MIN_BITCOIN_NUM = 0;                 // 最小比特币数量

    // 单次操作限制
    public static final int MAX_BITCOIN_PER_OPERATION = 1000000; // 单次操作最大数量
    public static final int MAX_BITCOIN_PER_EXCHANGE = 500;      // 单次兑换最大数量

    // 平台相关常量 (如果需要支持不同平台)
    public static final String DEFAULT_PLATFORM = "default";

    // 比特币兑换汇率(与 MoneyType.getBitcoinExchangeRate 保持一致)
    public static final int BTC_TO_SILVER_RATE = 100000;  // 1 BTC = 100,000 银币
    public static final int BTC_TO_GOLD_RATE = 1000;      // 1 BTC = 1,000 金币
    public static final int BTC_TO_QIAN_RATE = 100;       // 1 BTC = 100 仙玉
    public static final int BTC_TO_CASH_RATE = 10;        // 1 BTC = 10 元宝

    // 日志相关常量
    public static final String LOG_PREFIX = "BITCOIN";

    // 错误码
    public static final int ERROR_INSUFFICIENT_BITCOIN = -1001;   // 比特币不足
    public static final int ERROR_INVALID_AMOUNT = -1002;         // 无效金额
    public static final int ERROR_INVALID_USER = -1003;           // 无效用户
    public static final int ERROR_INVALID_ROLE = -1004;           // 无效角色
    public static final int ERROR_EXCEED_LIMIT = -1005;           // 超出限制
    public static final int ERROR_DATA_NOT_FOUND = -1006;         // 数据未找到
    public static final int ERROR_OPERATION_FAILED = -1007;       // 操作失败
}
