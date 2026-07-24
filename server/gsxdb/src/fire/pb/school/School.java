package fire.pb.school;

import fire.pb.main.ConfigManager;



/**
 * 门派枚举定义。
 * <p>
 * 该枚举仅作为门派的唯一程序内标识符。所有与门派相关的具体数据（如名称、NPC ID、称谓等）
 * 都已移至 {@link SchoolInfo} 类和 school.xml 配置文件中，并通过 {@link SchoolManager} 进行管理。
 * <p>
 * 这种设计遵循了“数据与逻辑分离”的原则，使得在未来扩展新门派时，无需修改任何Java代码，
 * 只需在配置文件中添加新条目即可。
 *
 * @see 学校经理
 * @查看学校信息
 * @参见配置管理器
 */
public enum School {
    WARRIOR(SchoolConst.WARRIOR),       // 11-大唐官府(物理输出)
    PALADIN(SchoolConst.PALADIN),       // 12-方寸山(封印控制)
    HUNTER(SchoolConst.HUNTER),         // 13-狮驼岭(物理爆发)
    DRUID(SchoolConst.DRUID),           // 14-阴曹地府(封印辅助)
    MAGIC(SchoolConst.MAGIC),           // 15-龙宫(法术输出)
    PRIEST(SchoolConst.PRIEST),         // 16-普陀山(治疗辅助)
    SAMAN(SchoolConst.SAMAN),           // 17-魔王寨(法术输出)
    ROGUE(SchoolConst.ROGUE),           // 18-化生寺(治疗辅助)
    WARLOCK(SchoolConst.WARLOCK),       // 19-月宫(法术输出)
    NUERCUN(SchoolConst.NUERCUN),       // 20-女儿村(封印控制)
    XIAOLEIYIN(SchoolConst.XIAOLEIYIN), // 21-小雷音(法术输出)
    HUAGUOSHAN(SchoolConst.HUAGUOSHAN), // 22-花果山(物理爆发)
    XUMIHAI(SchoolConst.XUMIHAI),       // 23-须弥海(封印辅助)
    PANSI(SchoolConst.PANSI);           // 24-盘丝洞(封印控制)

    private final int value;

    School(int value) {
        this.value = value;
    }

    public int getValue() { return value; } // 获取门派ID

    @Deprecated
    public int getNpcid() { // 获取首席弟子NPC ID，推荐用 school.getInfo().shouxiNpcId
        SchoolInfo info = getInfo();
        if (info != null) {
            return info.shouxiNpcId;
        }

        switch (this) {
            case WARRIOR: return SchoolConst.WARRIOR_SHOUXI;
            case PRIEST: return SchoolConst.PRIEST_SHOUXI;
            case PALADIN: return SchoolConst.PALADIN_SHOUXI;
            case HUNTER: return SchoolConst.HUNTER_SHOUXI;
            case WARLOCK: return SchoolConst.WARLOCK_SHOUXI;
            case SAMAN: return SchoolConst.SAMAN_SHOUXI;
            case MAGIC: return SchoolConst.MAGIC_SHOUXI;
            case ROGUE: return SchoolConst.ROGUE_SHOUXI;
            case DRUID: return SchoolConst.DRUID_SHOUXI;
            case NUERCUN: return SchoolConst.NUERCUN_SHOUXI;
            case XIAOLEIYIN: return SchoolConst.XIAOLEIYIN_SHOUXI;
            case HUAGUOSHAN: return SchoolConst.HUAGUOSHAN_SHOUXI;
            case XUMIHAI: return SchoolConst.XUMIHAI_SHOUXI;
            case PANSI: return SchoolConst.PANSI_SHOUXI;
            default: return 0;
        }
    }

    public SchoolInfo getInfo() { return SchoolManager.getSchoolInfo(this.value); } // 获取门派配置信息

    // 以下是静态工具方法，委托给 SchoolManager 实现

    @Deprecated
    public static School getSchoolBySchoolid(int schoolId) { // 根据门派ID获取枚举，推荐用 SchoolManager.getSchoolById
        School school = SchoolManager.getSchoolById(schoolId);
        if (school != null) {
            return school;
        }

        for (School s : School.values()) {
            if (s.value == schoolId) {
                return s;
            }
        }
        return null;
    }

    @Deprecated
    public static School getSchoolByNpcid(int npcId) { // 根据首席NPC ID获取枚举
        School school = SchoolManager.getSchoolByShouxiNpcId(npcId);
        if (school != null) return school;

        if (npcId == SchoolConst.WARRIOR_SHOUXI) return WARRIOR;
        if (npcId == SchoolConst.PRIEST_SHOUXI) return PRIEST;
        if (npcId == SchoolConst.PALADIN_SHOUXI) return PALADIN;
        if (npcId == SchoolConst.HUNTER_SHOUXI) return HUNTER;
        if (npcId == SchoolConst.WARLOCK_SHOUXI) return WARLOCK;
        if (npcId == SchoolConst.SAMAN_SHOUXI) return SAMAN;
        if (npcId == SchoolConst.MAGIC_SHOUXI) return MAGIC;
        if (npcId == SchoolConst.ROGUE_SHOUXI) return ROGUE;
        if (npcId == SchoolConst.DRUID_SHOUXI) return DRUID;
        if (npcId == SchoolConst.NUERCUN_SHOUXI) return NUERCUN;
        if (npcId == SchoolConst.XIAOLEIYIN_SHOUXI) return XIAOLEIYIN;
        if (npcId == SchoolConst.HUAGUOSHAN_SHOUXI) return HUAGUOSHAN;
        if (npcId == SchoolConst.XUMIHAI_SHOUXI) return XUMIHAI;
        if (npcId == SchoolConst.PANSI_SHOUXI) return PANSI;
        return null;
    }

    @Deprecated
    public static School getSchoolByBattleNpc(int battleNpcId) { // 根据战斗NPC ID获取枚举
        School school = SchoolManager.getSchoolByBattleNpcId(battleNpcId);
        if (school != null) return school;

        switch (battleNpcId) {
            case SchoolConst.WARRIOR_SHOUXI_BATTLE_NPC: return WARRIOR;
            case SchoolConst.PRIEST_SHOUXI_BATTLE_NPC: return PRIEST;
            case SchoolConst.PALADIN_SHOUXI_BATTLE_NPC: return PALADIN;
            case SchoolConst.HUNTER_SHOUXI_BATTLE_NPC: return HUNTER;
            case SchoolConst.WARLOCK_SHOUXI_BATTLE_NPC: return WARLOCK;
            case SchoolConst.SAMAN_SHOUXI_BATTLE_NPC: return SAMAN;
            case SchoolConst.MAGIC_SHOUXI_BATTLE_NPC: return MAGIC;
            case SchoolConst.ROGUE_SHOUXI_BATTLE_NPC: return ROGUE;
            case SchoolConst.DRUID_SHOUXI_BATTLE_NPC: return DRUID;
            case SchoolConst.NUERCUN_SHOUXI_BATTLE_NPC: return NUERCUN;
            case SchoolConst.XIAOLEIYIN_SHOUXI_BATTLE_NPC: return XIAOLEIYIN;
            case SchoolConst.HUAGUOSHAN_SHOUXI_BATTLE_NPC: return HUAGUOSHAN;
            case SchoolConst.XUMIHAI_SHOUXI_BATTLE_NPC: return XUMIHAI;
            case SchoolConst.PANSI_SHOUXI_BATTLE_NPC: return PANSI;
            default: return null;
        }
    }

    @Deprecated
    public static School getSchoolByFighterWinner(int battleId) { // 根据胜利战斗ID获取枚举
        School school = SchoolManager.getSchoolByFighterWinnerBattleId(battleId);
        if (school != null) {
            return school;
        }

        switch (battleId) {
            case 161803: return WARRIOR;
            case 161902: return PRIEST;
            case 162102: return PALADIN;
            case 162002: return HUNTER;
            case 169202: return WARLOCK;
            case 169102: return SAMAN;
            case 161702: return MAGIC;
            case 169002: return ROGUE;
            case 162202: return DRUID;
            default: return null;
        }
    }

    @Deprecated
    public static School getSchoolByFighterConfigWinner(int configId) { // 根据配置ID获取枚举
        School school = SchoolManager.getSchoolByFighterConfigWinnerId(configId);
        if (school != null) {
            return school;
        }

        switch (configId) {
            case 161803:
            case 3094:
                return WARRIOR;
            case 161902:
            case 3095:
                return PRIEST;
            case 162102:
            case 3097:
                return PALADIN;
            case 162002:
            case 3096:
                return HUNTER;
            case 169202:
            case 3101:
                return WARLOCK;
            case 169102:
            case 3100:
                return SAMAN;
            case 161702:
            case 3093:
                return MAGIC;
            case 169002:
            case 3099:
                return ROGUE;
            case 162202:
            case 3098:
                return DRUID;
            default:
                return null;
        }
    }

    @Deprecated
    public static int getBattleNpc(School school) { // 获取首席战斗NPC ID
        if (school == null) return 0;
        SchoolInfo info = school.getInfo();
        if (info != null && info.shouxiBattleNpcId > 0) return info.shouxiBattleNpcId;

        switch (school) {
            case WARRIOR: return SchoolConst.WARRIOR_SHOUXI_BATTLE_NPC;
            case PRIEST: return SchoolConst.PRIEST_SHOUXI_BATTLE_NPC;
            case PALADIN: return SchoolConst.PALADIN_SHOUXI_BATTLE_NPC;
            case HUNTER: return SchoolConst.HUNTER_SHOUXI_BATTLE_NPC;
            case WARLOCK: return SchoolConst.WARLOCK_SHOUXI_BATTLE_NPC;
            case SAMAN: return SchoolConst.SAMAN_SHOUXI_BATTLE_NPC;
            case MAGIC: return SchoolConst.MAGIC_SHOUXI_BATTLE_NPC;
            case ROGUE: return SchoolConst.ROGUE_SHOUXI_BATTLE_NPC;
            case DRUID: return SchoolConst.DRUID_SHOUXI_BATTLE_NPC;
            case NUERCUN: return SchoolConst.NUERCUN_SHOUXI_BATTLE_NPC;
            case XIAOLEIYIN: return SchoolConst.XIAOLEIYIN_SHOUXI_BATTLE_NPC;
            case HUAGUOSHAN: return SchoolConst.HUAGUOSHAN_SHOUXI_BATTLE_NPC;
            case XUMIHAI: return SchoolConst.XUMIHAI_SHOUXI_BATTLE_NPC;
            case PANSI: return SchoolConst.PANSI_SHOUXI_BATTLE_NPC;
            default: return 0;
        }
    }

    @Deprecated
    public static int getBattleIdBySchool(School school) { // 获取联盟赛战斗ID
        if (school == null) return 0;
        SchoolInfo info = school.getInfo();
        if (info != null && info.leagueBattleId > 0) return info.leagueBattleId;

        switch (school) {
            case MAGIC: return 3105;
            case WARRIOR: return 3106;
            case PRIEST: return 3107;
            case HUNTER: return 3108;
            case PALADIN: return 3109;
            case DRUID: return 3110;
            case ROGUE: return 3111;
            case SAMAN: return 3112;
            case WARLOCK: return 3113;
            default: return 0;
        }
    }

    @Deprecated
    public static int getShouxiTitleid(School school) { // 获取首席称谓ID
        if (school == null) return 0;
        SchoolInfo info = school.getInfo();
        if (info != null && info.shouxiTitleId > 0) return info.shouxiTitleId;

        switch (school) {
            case WARRIOR: return SchoolConst.WARRIOR_SHOUXI_TITLE;
            case PRIEST: return SchoolConst.PRIEST_SHOUXI_TITLE;
            case PALADIN: return SchoolConst.PALADIN_SHOUXI_TITLE;
            case HUNTER: return SchoolConst.HUNTER_SHOUXI_TITLE;
            case WARLOCK: return SchoolConst.WARLOCK_SHOUXI_TITLE;
            case SAMAN: return SchoolConst.SAMAN_SHOUXI_TITLE;
            case MAGIC: return SchoolConst.MAGIC_SHOUXI_TITLE;
            case ROGUE: return SchoolConst.ROGUE_SHOUXI_TITLE;
            case DRUID: return SchoolConst.DRUID_SHOUXI_TITLE;
            case NUERCUN: return SchoolConst.NUERCUN_SHOUXI_TITLE;
            case XIAOLEIYIN: return SchoolConst.XIAOLEIYIN_SHOUXI_TITLE;
            case HUAGUOSHAN: return SchoolConst.HUAGUOSHAN_SHOUXI_TITLE;
            case XUMIHAI: return SchoolConst.XUMIHAI_SHOUXI_TITLE;
            case PANSI: return SchoolConst.PANSI_SHOUXI_TITLE;
            default: return 0;
        }
    }

    @Deprecated
    public static int getTitleIdBySchool(int level, int sex, School school) { // 根据等级性别计算称谓ID
        int titleId = SchoolManager.getTitleId(school, level, sex);
        if (titleId > 0) return titleId;
        if (school == null || level <= 0) return 0;

        int malebaseid = 25, femalebaseid = 49;
        switch (school) {
            case WARRIOR: return sex == 1 ? malebaseid + 8 * (level - 1) + 0 : femalebaseid + 8 * (level - 1) + 0;
            case PRIEST: return sex == 1 ? malebaseid + 8 * (level - 1) + 6 : femalebaseid + 8 * (level - 1) + 6;
            case PALADIN: return sex == 1 ? malebaseid + 8 * (level - 1) + 1 : femalebaseid + 8 * (level - 1) + 1;
            case HUNTER: return sex == 1 ? malebaseid + 8 * (level - 1) + 2 : femalebaseid + 8 * (level - 1) + 2;
            case WARLOCK: return sex == 1 ? malebaseid + 8 * (level - 1) + 7 : femalebaseid + 8 * (level - 1) + 7;
            case SAMAN: return sex == 1 ? malebaseid + 8 * (level - 1) + 1 : femalebaseid + 8 * (level - 1) + 1;
            case MAGIC: return sex == 1 ? malebaseid + 8 * (level - 1) + 5 : femalebaseid + 8 * (level - 1) + 5;
            case ROGUE: return sex == 1 ? malebaseid + 8 * (level - 1) + 4 : femalebaseid + 8 * (level - 1) + 4;
            case DRUID: return sex == 1 ? malebaseid + 8 * (level - 1) + 3 : femalebaseid + 8 * (level - 1) + 3;
            default: return 0;
        }
    }
}
