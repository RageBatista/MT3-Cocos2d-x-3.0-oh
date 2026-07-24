//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MoneyType implements Marshal, Comparable<MoneyType> {
    public static final int MoneyType_None = 0; // 无效类型
    public static final int MoneyType_SilverCoin = 1; // 银币
    public static final int MoneyType_GoldCoin = 2;  // 金币
    public static final int MoneyType_HearthStone = 3; // 仙玉
    public static final int MoneyType_ProfContribute = 4;  // 职业贡献
    public static final int MoneyType_RongYu = 5; // 荣誉值
    public static final int MoneyType_FactionContribute = 6; // 公会贡献
    public static final int MoneyType_ShengWang = 7; // 声望
    public static final int MoneyType_FestivalPoint = 8; // 节日积分
    public static final int MoneyType_GoodTeacherVal = 9; // 良师值
    public static final int MoneyType_RoleExp = 10;  // 角色经验
    public static final int MoneyType_Activity = 11; // 活跃度
    public static final int MoneyType_Energy = 12;  // 活力
    public static final int MoneyType_EreditPoint = 13; // 信用点
    public static final int MoneyType_Bitcoin = 18; // 比特币
    public static final int MoneyType_Item = 99;  // 道具
    public static final int MoneyType_EarthlyPoint = 20;
    public static final int MoneyType_HeavenlyPoint = 21;
    public static final int MoneyType_PetPoint = 22;
    public static final int MoneyType_TreasureFragment = 23;
    public static final int MoneyType_TreasureSpirit = 24;
    public static final int MoneyType_BoundHearthStone = 109;
    public static final int MoneyType_WishCoin = 110;
    public static final int MoneyType_CaptainPoint = 111;
    public static final int MoneyType_Num = 25; // 类型数量

    public static String getMoneyTypeName(int moneyType) {
        switch (moneyType) {
            case 0:
                return "无效类型";
            case 1:
                return "银币";
            case 2:
                return "金币";
            case 3:
                return "仙玉";
            case 4:
                return "职业贡献";
            case 5:
                return "荣誉";
            case 6:
                return "帮派贡献";
            case 7:
                return "声望";
            case 8:
                return "节日积分";
            case 9:
                return "师德值";
            case 10:
                return "角色经验";
            case 11:
                return "每日活跃度";
            case 12:
                return "活力";
            case 13:
                return "信用值";
            case 18:
                return "比特币";
            case 20:
                return "地煞积分";
            case 21:
                return "天罡积分";
            case 22:
                return "宠物积分";
            case 23:
                return "法宝积分";
            case 24:
                return "法宝灵气";
            case 99:
                return "神兜兜";
            case 109:
                return "绑定仙玉";
            case 110:
                return "祈愿币";
            case 111:
                return "队长积分";
            default:
                return "未知货币类型(" + moneyType + ")";
        }
    }

    public static String validateMoneyOperation(int moneyType, long amount) {
        if (!isValidMoneyType(moneyType)) {
            return "无效的货币类型: " + moneyType;
        } else if (amount == 0L) {
            return "操作金额不能为0";
        } else {
            return Math.abs(amount) > 1152921504606846976L ? "操作金额超出允许范围" : null;
        }
    }

    public static boolean isValidMoneyType(int moneyType) {
        switch (moneyType) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 18:
            case 20:
            case 21:
            case 22:
            case 23:
            case 24:
            case 99:
            case 109:
            case 110:
            case 111:
                return true;
            default:
                return false;
        }
    }

    public static int getBitcoinExchangeRate(int toType) {
        switch (toType) {
            case 1:
                return 100000;
            case 2:
                return 1000;
            case 3:
                return 100;
            case 4:
                return 10;
            default:
                return 0;
        }
    }

    // 获取货币类型符号
    public static String getMoneyTypeSymbol(int moneyType) {
        switch (moneyType) {
            case MoneyType_SilverCoin:
                return "银";
            case MoneyType_GoldCoin:
                return "金";
            case MoneyType_HearthStone:
                return "玉";
            case MoneyType_Bitcoin:
                return "฿";
            case MoneyType_BoundHearthStone:
                return "绑玉";
            case MoneyType_WishCoin:
                return "愿";
            default:
                return "";
        }
    }

    // 判断是否为比特币
    public static boolean isBitcoin(int moneyType) {
        return moneyType == MoneyType_Bitcoin;
    }

    // 判断是否为基础货币（银币、金币、仙玉）
    public static boolean isBasicCurrency(int moneyType) {
        return moneyType == MoneyType_SilverCoin
            || moneyType == MoneyType_GoldCoin
            || moneyType == MoneyType_HearthStone;
    }

    // 判断是否为充值货币
    public static boolean isRechargeCurrency(int moneyType) {
        return moneyType == MoneyType_HearthStone
            || moneyType == MoneyType_BoundHearthStone;
    }

    // 格式化货币显示
    public static String formatMoneyDisplay(int moneyType, long amount) {
        String symbol = getMoneyTypeSymbol(moneyType);
        if (symbol.isEmpty()) {
            return String.valueOf(amount);
        }
        return amount + symbol;
    }

    // 计算比特币兑换
    public static long calculateBitcoinExchange(long bitcoinAmount, int targetType) {
        int rate = getBitcoinExchangeRate(targetType);
        if (rate == 0) {
            return 0L;
        }
        return bitcoinAmount * rate;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof MoneyType;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(MoneyType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
