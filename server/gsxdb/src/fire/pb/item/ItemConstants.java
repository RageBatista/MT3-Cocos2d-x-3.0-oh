package fire.pb.item;

/**
 * 物品系统常量定义类
 *
 * <p>集中管理所有物品相关的魔法数字，提高代码可维护性
 *
 * <h2>常量分类</h2>
 * <ul>
 *   <li>货币类型 - {@link CurrencyType}</li>
 *   <li>百宠系统配置 - {@link BaiChongConfig}</li>
 *   <li>系统消息ID - {@link SystemMessage}</li>
 *   <li>物品使用类型 - {@link ItemUseType}</li>
 * </ul>
 *
 * @author 由代码改进第 2 阶段生成
 * @版本2.0
 * @自2025年11月22日起
 */
public final class ItemConstants {

    // 禁止实例化
    private ItemConstants() {
        throw new AssertionError("常量类不允许实例化");
    }

    /**
     * 货币类型定义
     */
    public static final class CurrencyType {
        /** 金币 */
        public static final int GOLD = 4;

        /** 元宝/仙玉（高级货币） */
        public static final int YUAN_BAO = 18;

        /** 贡献值 */
        public static final int CONTRIBUTION = 4;

        private CurrencyType() {}
    }

    /**
     * 百宠许愿系统配置ID
     * <p>对应 SCommon 配置表的 ID
     */
    public static final class BaiChongConfig {
        /*单次许愿消耗（配置ID: 900） */
        public static final int SINGLE_WISH_COST = 900;

        /*10次​​许愿消耗（配置ID: 901） */
        public static final int TEN_WISH_COST = 901;

        /*金币奖励最小值（配置ID: 902） */
        public static final int GOLD_REWARD_MIN = 902;

        /*金币奖励货币类型（配置ID: 903） */
        public static final int GOLD_REWARD_TYPE = 903;

        /*金币奖励最大值（配置ID: 904） */
        public static final int GOLD_REWARD_MAX = 904;

        /** 10次许愿的次数 */
        public static final int TEN_TIMES = 10;

        /** 单次许愿的次数 */
        public static final int SINGLE_TIME = 1;

        private BaiChongConfig() {}
    }

    /**
     * 系统消息ID定义
     */
    public static final class SystemMessage {
        /** 金币不足，无法进行抽奖 */
        public static final int INSUFFICIENT_GOLD = 150552;

        /** 背包已满，无法获得奖励 / 抽奖成功 */
        public static final int BAG_FULL_OR_SUCCESS = 191226;

        private SystemMessage() {}
    }

    /**
     * 物品使用目标类型
     */
    public static final class ItemUseType {
        /** 对角色使用 */
        public static final int USE_TO_ROLE = 0;

        /** 对宠物使用 */
        public static final int USE_TO_PET = 1;

        /** 对物品使用 */
        public static final int USE_TO_ITEM = 2;

        /** 宠物装备分解 */
        public static final int PET_EQUIP_DECOMPOSE = 3;

        private ItemUseType() {}
    }

    /**
     * 物品使用数量类型
     */
    public static final class ItemUseAmount {
        /** 使用单个 */
        public static final int USE_SINGLE = 0;

        /** 使用全部 */
        public static final int USE_ALL = 1;

        private ItemUseAmount() {}
    }

    /**
     * 背包类型
     */
    public static final class BagType {
        /** 主背包 */
        public static final int MAIN_BAG = 1;

        /** 任务背包 */
        public static final int QUEST_BAG = 2;

        /** 临时背包 */
        public static final int TEMP_BAG = 3;

        private BagType() {}
    }

    /**
     * 物品数量类型（计数方式）
     */
    public static final class ItemCountType {
        /** 普通计数 */
        public static final int NORMAL = 0;

        /** 背包1计数 */
        public static final int BAG1 = 1;

        /** 背包2计数 */
        public static final int BAG2 = 2;

        private ItemCountType() {}
    }
}
