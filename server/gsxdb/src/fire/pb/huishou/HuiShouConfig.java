package fire.pb.huishou;

/**
 * 物品回收配置的数据映射类。
 * <p>
 * 用于承载从 huishou.xml 配置文件中读取的单个物品的回收规则。
 * 这是一个简单的数据容器 (POJO)，由 {@link HuiShouManager} 在服务器启动时加载和管理。
 * 其字段完全对应客户端文档中的 "item.chuishou" 表结构。
 */
public class HuiShouConfig {

    /**
     * 物品ID (与bean的id一致)
     */
    public int id;

    /**
     * 是否可回收 (1=可回收, 0=不可回收)。
     * 客户端会根据此字段判断是否显示回收按钮，服务器端也应进行校验。
     */
    public int canhuishou;

    /**
     * 回收后获得的奖励物品ID。
     */
    public int huishouitemid;

    /**
     * 回收单个物品后获得的奖励物品数量。
     */
    public int huishouitemnum;
}
