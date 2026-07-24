//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.baichong;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.common.SCommon;
import fire.pb.item.ItemConstants;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.item.SWish;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Random;
import java.util.TreeMap;
import mkdb.Procedure;

/**
 * 百宠许愿系统 - 服务端处理逻辑
 *
 * <p>功能说明：
 * <ul>
 *   <li>支持单次许愿和10连抽</li>
 *   <li>扣除货币后进行概率抽奖</li>
 *   <li>奖励物品和随机金币</li>
 * </ul>
 *
 * @see fire.pb.item.baichong.CWish 客户端请求协议
 * @see fire.pb.item.baichong.SWishRet 服务端响应协议
 */
public class PWish extends Procedure {
    private final long roleId;
    private final int times;

    /**
     * 创建许愿处理对象
     * @param roleId 角色ID
     * @param times 许愿次数（1或10）
     */
    public PWish(long roleId, int times) {
        this.roleId = roleId;
        this.times = times;
    }

    protected boolean process() {
        // 从配置表获取许愿相关参数
        int wishCost = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class)
                .get(ItemConstants.BaiChongConfig.SINGLE_WISH_COST)).getValue());
        int goldRewardMin = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class)
                .get(ItemConstants.BaiChongConfig.GOLD_REWARD_MIN)).getValue());
        int goldRewardType = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class)
                .get(ItemConstants.BaiChongConfig.GOLD_REWARD_TYPE)).getValue());
        int goldRewardMax = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class)
                .get(ItemConstants.BaiChongConfig.GOLD_REWARD_MAX)).getValue());
        long totalGoldReward = 0L;

        // 10连抽使用不同的消耗配置
        if (this.times == ItemConstants.BaiChongConfig.TEN_TIMES) {
            wishCost = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class)
                    .get(ItemConstants.BaiChongConfig.TEN_WISH_COST)).getValue());
        }

        Pack pack = new Pack(this.roleId, false);
        // 扣除许愿所需货币
        long subResult = pack.subCurrency((long)(-wishCost),
                ItemConstants.CurrencyType.YUAN_BAO,
                "百宠许愿抽奖",
                YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
        if (subResult == 0L) {
            List<String> params = new ArrayList();
            params.add("金币不足，无法进行抽奖");
            MessageMgr.psendMsgNotify(this.roleId, ItemConstants.SystemMessage.INSUFFICIENT_GOLD, params);
            return false;
        } else {
            ArrayList arrayList = new ArrayList();
            ArrayList arrayList2 = new ArrayList();
            TreeMap<Integer, SWish> conf = ConfigManager.getInstance().getConf(SWish.class);

            for(SWish sWish : conf.values()) {
                for(int i = 0; i < sWish.getProbability(); ++i) {
                    arrayList2.add(sWish.getItemid());
                }
            }

            SWishRet sWishRet = new SWishRet();
            Random random = new Random();

            for(int i2 = 1; i2 <= this.times; ++i2) {
                int nextInt = random.nextInt(arrayList2.size());
                sWishRet.datas.put(i2, (Integer)arrayList2.get(nextInt));
                ItemMaps bag2 = Module.getInstance().getItemMaps(this.roleId, 1, false);
                int addNum = bag2.doAddItem((Integer)arrayList2.get(nextInt), 1, "wish", YYLoggerTuJingEnum.tujing_Value_mailget, (Integer)arrayList2.get(nextInt));
                if (addNum != 1) {
                    List<String> params = new ArrayList();
                    params.add("背包已满，无法获得奖励，抽奖失败");
                    MessageMgr.psendMsgNotify(this.roleId, ItemConstants.SystemMessage.BAG_FULL_OR_SUCCESS, params);
                    return false;
                }

                // 累加随机金币奖励
                totalGoldReward += (long)(random.nextInt(goldRewardMax - goldRewardMin) + goldRewardMin);
            }

            // 发放金币奖励
            pack.addSysCurrency(totalGoldReward, goldRewardType, "wish", YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
            arrayList.add(String.valueOf(totalGoldReward));
            List<String> params = new ArrayList();
            params.add("<T t='恭喜抽奖获得' c='ffFFFE7A'/><T t='[" + totalGoldReward + "] ' c='FFF40754'/><T t='金币' c='ffFFFE7A'/>");
            MessageMgr.psendMsgNotify(this.roleId, ItemConstants.SystemMessage.BAG_FULL_OR_SUCCESS, params);
            Procedure.psendWhileCommit(this.roleId, sWishRet);
            return true;
        }
    }

    public static long GetOneDay1Millisecond() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(11, 0);
        calendar.set(12, 0);
        calendar.set(13, 0);
        calendar.set(14, 1);
        return calendar.getTimeInMillis();
    }
}
