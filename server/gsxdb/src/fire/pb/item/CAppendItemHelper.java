package fire.pb.item;

/**
 * CAppendItem 协议辅助工具类
 *
 * <p>提供物品使用协议的辅助方法
 *
 * @author 由代码改进第 2 阶段生成
 * @版本1.0
 * @自2025年11月22日起
 */
final class CAppendItemHelper {

    private CAppendItemHelper() {
        throw new AssertionError("工具类不允许实例化");
    }

    /**
     * 根据 isalluse 标识计算实际使用数量类型
     *
     * @param isalluse 使用方式（0=单个, 1=全部）
     * @return 使用数量（1=单个, 2=全部）
     */
    static int calculateUseNum(int isalluse) {
        if (isalluse == ItemConstants.ItemUseAmount.USE_SINGLE) {
            return 1;  // 使用单个
        }
        if (isalluse == ItemConstants.ItemUseAmount.USE_ALL) {
            return 2;  // 使用全部
        }
        return 0;  // 默认不使用
    }
}
