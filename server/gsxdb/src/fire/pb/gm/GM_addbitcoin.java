//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.game.MoneyType;
import fire.pb.item.Pack;
import mkdb.Procedure;

public class GM_addbitcoin extends GMCommand {
    private static final long MAX_BITCOIN_PER_OPERATION = 1000L;
    private static final long MAX_CURRENCY_VALUE = 1152921504606846976L;
    private static final long MIN_CURRENCY_VALUE = -1152921504606846976L;

    boolean exec(String[] args) {
        if (args.length < 1) {
            this.sendToGM("❌ 参数格式错误：" + this.usage());
            return false;
        } else {
            try {
                final long bitcoinAmount = Long.parseLong(args[0]);
                if (bitcoinAmount == 0L) {
                    this.sendToGM("⚠️ 比特币数量不能为0");
                    return false;
                } else if (bitcoinAmount <= 1152921504606846976L && bitcoinAmount >= -1152921504606846976L) {
                    if (Math.abs(bitcoinAmount) > 1000L) {
                        this.sendToGM("⚠️ 单次操作比特币数量不能超过 1000");
                        return false;
                    } else {
                        final long roleid;
                        if (args.length >= 2) {
                            roleid = Long.valueOf(args[1]);
                        } else {
                            roleid = this.getGmroleid();
                        }

                        (new Procedure() {
                            protected boolean process() {
                                try {
                                    String validationError = MoneyType.validateMoneyOperation(18, bitcoinAmount);
                                    if (validationError != null) {
                                        GM_addbitcoin.this.sendToGM("❌ 操作验证失败: " + validationError);
                                        return false;
                                    } else {
                                        Pack bag = new Pack(roleid, false);
                                        long beforeBalance = bag.getCurrency(18);
                                        GM_addbitcoin.this.sendToGM("添加前比特币余额: " + beforeBalance);
                                        GM_addbitcoin.this.sendToGM("准备添加比特币: " + bitcoinAmount + " (类型: " + 18 + ")");
                                        long result = bag.addSysCurrency(bitcoinAmount, 18, "GM指令 加比特币", YYLoggerTuJingEnum.GM, 0);
                                        long afterBalance = bag.getCurrency(18);
                                        GM_addbitcoin.this.sendToGM("addSysCurrency返回值: " + result);
                                        GM_addbitcoin.this.sendToGM("添加后比特币余额: " + afterBalance);
                                        GM_addbitcoin.this.recordBitcoinOperation(bitcoinAmount);
                                        String operation = bitcoinAmount > 0L ? "添加" : "扣除";
                                        String message = String.format("成功为角色 %d %s %d 比特币", roleid, operation, Math.abs(bitcoinAmount));
                                        GM_addbitcoin.this.sendToGM(message);
                                        return true;
                                    }
                                } catch (Exception e) {
                                    GM_addbitcoin.this.sendToGM("❌ 比特币操作失败: " + e.getMessage());
                                    return false;
                                }
                            }
                        }).submit();
                        return true;
                    }
                } else {
                    this.sendToGM("❌ 比特币数量超出有效范围 [-1152921504606846976, 1152921504606846976]");
                    return false;
                }
            } catch (NumberFormatException var6) {
                this.sendToGM("❌ 参数格式错误：比特币数量必须是数字");
                return false;
            } catch (Exception e) {
                this.sendToGM("❌ 添加比特币失败：" + e.getMessage());
                return false;
            }
        }
    }

    String usage() {
        return "addbitcoin [比特币数量] [角色ID(可选)]";
    }

    private void recordBitcoinOperation(long amount) {
        try {
            String operation = amount > 0L ? "ADD" : "SUBTRACT";
            this.logGMOperation("BITCOIN_" + operation, "Amount: " + Math.abs(amount) + " BTC");
        } catch (Exception e) {
            logger.error("Failed to record bitcoin operation statistics", e);
        }

    }
}
