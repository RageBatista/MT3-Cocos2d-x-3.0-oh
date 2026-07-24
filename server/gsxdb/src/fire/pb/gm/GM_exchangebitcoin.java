//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import java.util.HashMap;
import java.util.Map;
import mkdb.Procedure;

public class GM_exchangebitcoin extends GMCommand {
    private static final int BTC_TO_CASH_RATE = 10;
    private static final int BTC_TO_QIAN_RATE = 100;
    private static final int BTC_TO_GOLD_RATE = 1000;
    private static final int BTC_TO_MONEY_RATE = 100000;
    private static final long MAX_BITCOIN_PER_EXCHANGE = 500L;
    private static final Map<String, ExchangeInfo> EXCHANGE_TYPES = new HashMap<>();

    boolean exec(String[] args) {
        if (args.length < 2) {
            this.sendToGM("❌ 参数格式错误：" + this.usage());
            return false;
        } else {
            try {
                String exchangeType = args[0].toLowerCase();
                final long bitcoinAmount = Long.parseLong(args[1]);
                final ExchangeInfo exchangeInfo = (ExchangeInfo)EXCHANGE_TYPES.get(exchangeType);
                if (exchangeInfo == null) {
                    this.sendToGM("❌ 不支持的兑换类型：" + exchangeType);
                    this.sendToGM("\ud83d\udca1 支持的类型：cash(元宝), qian(仙玉), gold(金币), money(银币)");
                    return false;
                } else if (bitcoinAmount <= 0L) {
                    this.sendToGM("❌ 比特币数量必须大于0");
                    return false;
                } else if (bitcoinAmount > 500L) {
                    this.sendToGM("⚠️ 单次兑换比特币数量不能超过 500");
                    return false;
                } else {
                    final long roleid;
                    if (args.length >= 3) {
                        roleid = Long.valueOf(args[2]);
                    } else {
                        roleid = this.getGmroleid();
                    }

                    (new Procedure() {
                        protected boolean process() {
                            try {
                                Pack bag = new Pack(roleid, false);
                                long exchangeAmount = bitcoinAmount * (long)exchangeInfo.rate;
                                boolean success = GM_exchangebitcoin.this.performExchange(bag, exchangeInfo, bitcoinAmount, exchangeAmount);
                                if (success) {
                                    bag.addSysCurrency(-bitcoinAmount, 18, "兑换" + exchangeInfo.displayName, YYLoggerTuJingEnum.GM, 0);
                                    GM_exchangebitcoin.this.recordExchangeOperation(bitcoinAmount, exchangeInfo.displayName, exchangeAmount);
                                    String message = String.format("兑换成功：%d 比特币 → %d %s (角色: %d)", bitcoinAmount, exchangeAmount, exchangeInfo.displayName, roleid);
                                    GM_exchangebitcoin.this.sendToGM(message);
                                    GM_exchangebitcoin.this.sendToGM(String.format("汇率：1 BTC = %d %s", exchangeInfo.rate, exchangeInfo.displayName));
                                    return true;
                                } else {
                                    GM_exchangebitcoin.this.sendToGM("兑换操作失败");
                                    return false;
                                }
                            } catch (Exception e) {
                                GM_exchangebitcoin.this.sendToGM("❌ 兑换失败：" + e.getMessage());
                                return false;
                            }
                        }
                    }).submit();
                    return true;
                }
            } catch (NumberFormatException var9) {
                this.sendToGM("❌ 参数格式错误：比特币数量必须是数字");
                return false;
            } catch (Exception e) {
                this.sendToGM("❌ 兑换失败：" + e.getMessage());
                return false;
            }
        }
    }

    private boolean performExchange(Pack bag, ExchangeInfo exchangeInfo, long bitcoinAmount, long exchangeAmount) {
        try {
            switch (exchangeInfo.currencyType) {
                case 1:
                    bag.addSysMoney(exchangeAmount, "比特币兑换银币", YYLoggerTuJingEnum.GM, 0);
                    break;
                case 2:
                    bag.addSysGold(exchangeAmount, "比特币兑换金币", YYLoggerTuJingEnum.GM, 0);
                    break;
                case 3:
                    bag.addSysCurrency(exchangeAmount, 3, "比特币兑换仙玉", YYLoggerTuJingEnum.GM, 0);
                    break;
                case 4:
                    bag.addSysCurrency(exchangeAmount, 4, "比特币兑换元宝", YYLoggerTuJingEnum.GM, 0);
                    break;
                default:
                    return false;
            }

            return true;
        } catch (Exception e) {
            System.err.println("Exchange operation failed: " + e.getMessage());
            return false;
        }
    }

    String usage() {
        return "exchangebitcoin [兑换类型] [比特币数量] [角色ID(可选)]";
    }

    private void recordExchangeOperation(long bitcoinAmount, String targetCurrency, long exchangeAmount) {
        try {
            this.logGMOperation("BITCOIN_EXCHANGE", String.format("%d BTC → %d %s", bitcoinAmount, exchangeAmount, targetCurrency));
        } catch (Exception e) {
            logger.error("Failed to record bitcoin exchange statistics", e);
        }

    }

    static {
        EXCHANGE_TYPES.put("cash", new ExchangeInfo(4, 10, "元宝"));
        EXCHANGE_TYPES.put("元宝", new ExchangeInfo(4, 10, "元宝"));
        EXCHANGE_TYPES.put("qian", new ExchangeInfo(3, 100, "仙玉"));
        EXCHANGE_TYPES.put("仙玉", new ExchangeInfo(3, 100, "仙玉"));
        EXCHANGE_TYPES.put("gold", new ExchangeInfo(2, 1000, "金币"));
        EXCHANGE_TYPES.put("金币", new ExchangeInfo(2, 1000, "金币"));
        EXCHANGE_TYPES.put("money", new ExchangeInfo(1, 100000, "银币"));
        EXCHANGE_TYPES.put("银币", new ExchangeInfo(1, 100000, "银币"));
    }

    private static class ExchangeInfo {
        final int currencyType;
        final int rate;
        final String displayName;

        ExchangeInfo(int currencyType, int rate, String displayName) {
            this.currencyType = currencyType;
            this.rate = rate;
            this.displayName = displayName;
        }
    }
}
