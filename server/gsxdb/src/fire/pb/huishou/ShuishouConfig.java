package fire.pb.huishou;

/**
 * 物品回收配置的数据映射类 (POJO)。
 * <p>
 * 该类的结构精确匹配 gamedata/xml/auto/fire.pb.huishou.ShuishouConfigmap.xml 文件中的定义。
 * 由 {@link fire.pb.main.ConfigManager} 在服务器启动时自动加载。
 */
public class ShuishouConfig {

    /**
     * 物品ID (与bean的key一致)
     */
    public int id;

    /**
     * 回收后获得的奖励物品ID。
     * 对应XML中的 "huishouitem" 属性。
     */
    public int huishouitem;

    /**
     * 回收单个物品后获得的奖励物品数量。
     * 对应XML中的 "huishounum" 属性。
     */
    public int huishounum;
}
