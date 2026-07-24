package fire.pb.huishou;

import fire.pb.main.ConfigManager;
import org.apache.log4j.Logger;

import java.util.Map;

/**
 * 物品回收系统管理器。
 * <p>
 * 负责在服务器启动时加载所有物品回收配置, 并提供统一的查询接口。
 */
public class HuiShouManager {
    private static final Logger logger = Logger.getLogger("HUISHOU");

    // 存储所有物品的回收配置信息, Key: 物品ID
    private static Map<Integer, HuiShouConfig> huiShouConfigMap;

    private HuiShouManager() {
    }

    /**
     * 初始化管理器, 在服务器启动时调用。
     */
    public static void init() {
        logger.info("开始加载物品回收系统配置...");
        huiShouConfigMap = ConfigManager.getInstance().getConf(HuiShouConfig.class);
        if (huiShouConfigMap == null) {
            throw new RuntimeException("加载物品回收配置失败, 请检查 gamedata/xml/huishou.xml 文件是否存在或配置有误。");
        }
        logger.info("物品回收系统配置加载完成。共加载 " + huiShouConfigMap.size() + " 个物品回收规则。");
    }

    /**
     * 根据物品ID获取其回收配置。
     *
     * @param itemId 物品ID
     * @return HuiShouConfig 对象, 如果该物品不可回收或无配置则返回 null
     */
    public static HuiShouConfig getConfig(int itemId) {
        if (huiShouConfigMap == null) {
            logger.error("物品回收管理器尚未初始化！");
            return null;
        }
        return huiShouConfigMap.get(itemId);
    }

    /**
     * 检查一个物品是否可以被回收。
     *
     * @param itemId 物品ID
     * @return 如果可以回收则返回 true, 否则返回 false
     */
    public static boolean canRecycle(int itemId) {
        HuiShouConfig config = getConfig(itemId);
        return config != null && config.canhuishou == 1;
    }
}
