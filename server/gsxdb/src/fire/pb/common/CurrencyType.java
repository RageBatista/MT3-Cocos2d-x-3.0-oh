//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.common;

import fire.pb.game.MoneyType;

public class CurrencyType {
    public static final int CURRENCY_TYPE_MONEY = 1;
    public static final int CURRENCY_TYPE_GOLD = 2;
    public static final int CURRENCY_TYPE_QIAN = 3;
    public static final int CURRENCY_TYPE_CASH = 4;
    public static final int CURRENCY_TYPE_BITCOIN = 18;

    public static String getCurrencyName(int currencyType) {
        return MoneyType.getMoneyTypeName(currencyType);
    }

    public static String getCurrencySymbol(int currencyType) {
        return MoneyType.getMoneyTypeSymbol(currencyType);
    }

    public static boolean isValidCurrencyType(int currencyType) {
        return MoneyType.isValidMoneyType(currencyType);
    }

    public static boolean isBitcoin(int currencyType) {
        return MoneyType.isBitcoin(currencyType);
    }

    public static boolean isBasicCurrency(int currencyType) {
        return MoneyType.isBasicCurrency(currencyType);
    }

    public static boolean isRechargeCurrency(int currencyType) {
        return MoneyType.isRechargeCurrency(currencyType);
    }

    public static String formatCurrency(int currencyType, long amount) {
        return MoneyType.formatMoneyDisplay(currencyType, amount);
    }

    public static long getBitcoinExchangeRate(int targetCurrencyType) {
        return MoneyType.getBitcoinExchangeRate(targetCurrencyType);
    }

    public static long calculateBitcoinExchange(long bitcoinAmount, int targetCurrencyType) {
        return MoneyType.calculateBitcoinExchange(bitcoinAmount, targetCurrencyType);
    }
}
