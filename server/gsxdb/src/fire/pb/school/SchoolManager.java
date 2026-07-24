package fire.pb.school;

import fire.pb.main.ConfigManager;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 门派系统管理器
 * <p>
 * 负责在服务器启动时加载所有门派配置, 并提供统一的查询接口。
 * 该类替代了原 School 枚举中大量的 switch-case 逻辑, 实现了数据与逻辑的分离。
 */
public class SchoolManager {
    private static final Logger logger = Logger.getLogger("SCHOOL");

    // 存储所有门派的配置信息, Key: 门派ID
    private static final Map<Integer, SchoolInfo> schoolInfoMap = new HashMap<>();
    // 反向映射, 用于通过各种ID快速查找门派, Key: ID, Value: 门派ID
    private static final Map<Integer, Integer> shouxiNpcIdToSchoolId = new HashMap<>();
    private static final Map<Integer, Integer> shouxiBattleNpcIdToSchoolId = new HashMap<>();
    private static final Map<Integer, Integer> fighterWinnerBattleIdToSchoolId = new HashMap<>();
    private static final Map<Integer, Integer> fighterConfigWinnerIdToSchoolId = new HashMap<>();

    private SchoolManager() {
    }

    /**
     * 初始化管理器, 在服务器启动时调用。
     */
    public static void init() {
        logger.info("开始加载门派系统配置...");
        // 从 ConfigManager 加载 school.xml 中所有 SchoolInfo 类型的配置
        Map<Integer, SchoolInfo> configs = ConfigManager.getInstance().getConf(SchoolInfo.class);
        if (configs == null) {
            throw new RuntimeException("加载门派配置失败, 请检查 gamedata/xml/school.xml 文件是否存在或配置有误。");
        }

        for (SchoolInfo info : configs.values()) {
            // 校验枚举名称是否存在
            try {
                School.valueOf(info.enumName);
            } catch (IllegalArgumentException e) {
                logger.error("门派配置错误: school.xml 中 enumName '" + info.enumName + "' 在 School.java 枚举中不存在。", e);
                continue; // 跳过无效配置
            }

            schoolInfoMap.put(info.id, info);

            // 建立反向映射, 方便快速查找
            if (info.shouxiNpcId > 0) {
                shouxiNpcIdToSchoolId.put(info.shouxiNpcId, info.id);
            }
            if (info.shouxiBattleNpcId > 0) {
                shouxiBattleNpcIdToSchoolId.put(info.shouxiBattleNpcId, info.id);
            }
            if (info.fighterWinnerBattleId > 0) {
                fighterWinnerBattleIdToSchoolId.put(info.fighterWinnerBattleId, info.id);
            }
            if (info.fighterConfigWinnerIds != null) {
                for (Integer configId : info.fighterConfigWinnerIds) {
                    fighterConfigWinnerIdToSchoolId.put(configId, info.id);
                }
            }
        }

        // 校验 School 枚举中的所有门派是否都有配置
        for (School school : School.values()) {
            if (!schoolInfoMap.containsKey(school.getValue())) {
                logger.warn("门派校验警告: School.java 枚举中的门派 " + school.name() + " (ID: " + school.getValue() + ") 在 school.xml 中没有找到对应的配置。");
            }
        }

        logger.info("门派系统配置加载完成。共加载 " + schoolInfoMap.size() + " 个门派。");
        logger.info("门派ID映射: " + schoolInfoMap.keySet().stream().map(String::valueOf).collect(Collectors.joining(", ")));
    }

    /**
     * 根据门派ID获取完整的门派配置信息。
     *
     * @param schoolId 门派ID
     * @return SchoolInfo 对象, 如果不存在则返回 null
     */
    public static SchoolInfo getSchoolInfo(int schoolId) {
        return schoolInfoMap.get(schoolId);
    }

    /**
     * 根据门派ID获取门派枚举。
     *
     * @param schoolId 门派ID
     * @return School 枚举, 如果不存在则返回 null
     */
    public static School getSchoolById(int schoolId) {
        SchoolInfo info = getSchoolInfo(schoolId);
        if (info != null) {
            try {
                return School.valueOf(info.enumName);
            } catch (IllegalArgumentException e) {
                // 这个异常理论上在init时已经被捕获, 这里做个兜底
                return null;
            }
        }
        return null;
    }

    /**
     * 根据首席弟子NPC ID获取门派枚举。
     *
     * @param npcId 首席NPC ID
     * @return School 枚举, 如果不存在则返回 null
     */
    public static School getSchoolByShouxiNpcId(int npcId) {
        Integer schoolId = shouxiNpcIdToSchoolId.get(npcId);
        return schoolId != null ? getSchoolById(schoolId) : null;
    }

    /**
     * 根据首席竞选战斗NPC ID获取门派枚举。
     *
     * @param battleNpcId 战斗NPC ID
     * @return School 枚举, 如果不存在则返回 null
     */
    public static School getSchoolByBattleNpcId(int battleNpcId) {
        Integer schoolId = shouxiBattleNpcIdToSchoolId.get(battleNpcId);
        return schoolId != null ? getSchoolById(schoolId) : null;
    }

    /**
     * 根据首席竞选胜利战斗ID获取门派枚举。
     *
     * @param battleId 战斗ID
     * @return School 枚举, 如果不存在则返回 null
     */
    public static School getSchoolByFighterWinnerBattleId(int battleId) {
        Integer schoolId = fighterWinnerBattleIdToSchoolId.get(battleId);
        return schoolId != null ? getSchoolById(schoolId) : null;
    }

    /**
     * 根据首席竞选胜利配置ID获取门派枚举。
     *
     * @param configId 配置ID
     * @return School 枚举, 如果不存在则返回 null
     */
    public static School getSchoolByFighterConfigWinnerId(int configId) {
        Integer schoolId = fighterConfigWinnerIdToSchoolId.get(configId);
        return schoolId != null ? getSchoolById(schoolId) : null;
    }

    /**
     * 根据门派和等级、性别计算称谓ID。
     *
     * @param school 门派枚举
     * @param level  称谓等级 (1, 2, 3...)
     * @param sex    性别 (e.g., 1 for male, 2 for female)
     * @return 称谓ID, 如果门派不存在或参数错误则返回 0
     */
    public static int getTitleId(School school, int level, int sex) {
        SchoolInfo info = getSchoolInfo(school.getValue());
        if (info == null || level <= 0) {
            return 0;
        }

        int baseId = (sex == 1) ? info.maleTitleBaseId : info.femaleTitleBaseId;
        if (baseId == 0) {
            return 0;
        }

        // 假设公式为: base + 8 * (level - 1) + offset
        return baseId + 8 * (level - 1) + info.titleOffset;
    }
}
