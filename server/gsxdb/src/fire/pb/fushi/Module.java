//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import fire.pb.main.ConfigManager;
import fire.pb.main.ModuleInterface;
import fire.pb.main.ReloadResult;
import fire.pb.util.FireProp;
import java.util.HashMap;
import java.util.Map;
import xbean.AUUserInfo;
import xbean.Pod;
import xbean.Vipinfo;
import xtable.Auuserinfo;

public class Module implements ModuleInterface {
    public static final int CREDITPOINT_IN_EXCHANGE = 1;
    public static final int CREDITPOINT_IN_SALL_RARE = 2;
    public static final int CREDITPOINT_IN_SALL = 3;
    public static final int CREDITPOINT_IN_WORLD_BONUS = 4;
    public static final int CREDITPOINT_IN_CLAN_BONUS = 5;
    public static final int CREDITPOINT_OUT_BUY = 6;
    public static final int CREDITPOINT_OUT_BUY_RARE = 7;
    public static final int CREDITPOINT_ONBORN = 8;
    public static final int CREDITPOINT_IN_FS2GOLD = 9;
    public static final int CREDITPOINT_IN_OPENGOLDBOX = 10;
    public static final int CREDITPOINT_IN_OPENSILVERBOX = 11;
    public static final int CREDITPOINT_IN_BUYGOLDBOX = 12;
    public static final int CREDITPOINT_IN_FSBUYGOLD = 13;
    public static final int CREDITPOINT_OUT_GOLD2FS = 14;
    public static final int CREDITPOINT_IN_DAYCOSTFUSHI = 15;
    public static final int CREDITPOINT_IN_TEAM_BONUS = 16;
    public static final int CREDITPOINT_OUT_WORLD_BONUS = 17;
    public static final int CREDITPOINT_OUT_CLAN_BONUS = 18;
    public static final int CREDITPOINT_OUT_TEAM_BONUS = 19;
    public static final int CREDITPOINT_RETURN_WORLD_BONUS = 20;
    public static final int CREDITPOINT_RETURN_CLAN_BONUS = 21;
    public static final int CREDITPOINT_RETURN_TEAM_BONUS = 22;
    public static final int CREDITPOINT_IN_GOLD_DRAGON = 23;
    public static final int CREDITPOINT_IN_GOLD_HYD_BONUS = 24;
    public static final int CREDITPOINT_IN_RETURN_GOLD2FS = 25;
    public static final int CREDITPOINT_OUT_CBG = 26;
    public static final int CREDITPOINT_IN_CBG = 27;
    public static final int CREDITPOINT_END = 28;
    public static Map<Integer, Double> CreditPointMap = new HashMap();
    public static final int PayServerType = FireProp.getIntValue(ConfigManager.getInstance().getPropConf("sys"), "sys.payserver.type");

    public void exit() {
    }

    public void init() throws Exception {
        FushiManager.getInstance().init();
    }

    public ReloadResult reload() throws Exception {
        FushiManager.logger.info("fushi reload start!");
        FushiManager.getInstance().initChargeGoodList();
        initCreditPoint();
        FushiManager.logger.info("fushi reload success!");
        return new ReloadResult(true);
    }

    public static int GetPayServiceType() {
        return PayServerType;
    }

    public static SVipInfoConfig getVipInfoConfig(int level) {
        return (SVipInfoConfig)ConfigManager.getInstance().getConf(SVipInfoConfig.class).get(level);
    }

    public static void initCreditPoint() {
        CreditPointMap.clear();

        for(int i = 1; i < 28; ++i) {
            int index = i + PayServerType * 100;
            SCreditPoint creditPoint = (SCreditPoint)ConfigManager.getInstance().getConf(SCreditPoint.class).get(index);
            if (creditPoint != null) {
                CreditPointMap.put(i, creditPoint.eventvalue);
            } else {
                FushiManager.logger.info("load CreditPoint info error! index:" + index + "的信息找不到！");
            }
        }

    }

    public static float getCreditPointValue(int nType) {
        return CreditPointMap.containsKey(nType) ? ((Double)CreditPointMap.get(nType)).floatValue() : 0.0F;
    }

    public static int getVipTableRight(long roleid, int nType) {
        Vipinfo vipinfo = xtable.Vipinfo.get(roleid);
        if (null == vipinfo) {
            vipinfo = Pod.newVipinfo();
            xtable.Vipinfo.insert(roleid, vipinfo);
        }

        if (vipinfo.getViplevel() > 0) {
            SVipInfoConfig cfg = getVipInfoConfig(vipinfo.getViplevel());
            if (cfg != null) {
                return (Integer)cfg.viprights.get(nType);
            }
        }

        return 0;
    }

    public static int getVipTableRightOfLevel(int type, int level) {
        if (level > 0) {
            SVipInfoConfig cfg = getVipInfoConfig(level);
            if (cfg != null) {
                return (Integer)cfg.viprights.get(type);
            }
        }

        return 0;
    }

    public static boolean getIsYYBUser(int userid) {
        AUUserInfo auUserInfo = Auuserinfo.select(userid);
        if (auUserInfo == null) {
            FushiManager.logger.info((new StringBuilder()).append("userid:").append(userid).append(",is null"));
            return false;
        } else {
            return auUserInfo.getPlatname().equals("yingyongbao");
        }
    }
}
