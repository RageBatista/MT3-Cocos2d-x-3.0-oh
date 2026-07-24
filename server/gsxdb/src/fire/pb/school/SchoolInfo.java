package fire.pb.school;

import java.util.ArrayList;
import java.util.List;

/**
 * 门派配置信息数据类
 * 承载从 school.xml 读取的门派属性，由 SchoolManager 加载管理
 * 配置路径: gamedata/xml/school.xml
 *
 * @see 学校经理
 * @见学校
 */
public class SchoolInfo {

    // ==================== 基础标识 ====================
    public int id;                  // 门派ID (11-24)
    public String enumName;         // 枚举名称，须与 School.java 一致 (WARRIOR/PALADIN/MAGIC...)
    public String name;             // 中文名称 (大唐官府/方寸山/龙宫...)

    // ==================== 首席弟子 ====================
    public int shouxiNpcId;         // 首席弟子NPC ID
    public int shouxiTitleId;       // 首席弟子称谓ID
    public int shouxiBattleNpcId;   // 首席竞选战斗NPC ID

    // ==================== 战斗相关 ====================
    public int leagueBattleId;      // 联盟赛战斗ID
    public int fighterWinnerBattleId;                           // 首席竞选胜利战斗ID (反查用)
    public List<Integer> fighterConfigWinnerIds = new ArrayList<>(); // 首席竞选胜利配置ID列表

    // ==================== 称谓计算 ====================
    // 公式：baseId + 8 * (level - 1) + offset
    public int maleTitleBaseId;     // 男性称谓基础ID
    public int femaleTitleBaseId;   // 女性称谓基础ID
    public int titleOffset;         // 称谓偏移量 (区分不同门派)
}
