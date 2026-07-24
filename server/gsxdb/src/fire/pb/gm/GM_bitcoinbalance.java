//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.fushi.Module;
import fire.pb.item.Pack;
import mkdb.Procedure;
import xbean.YbNum;
import xbean.YbNums;
import xbean.YybFushiNum;
import xbean.YybFushiNums;
import xtable.Fushinum;
import xtable.Properties;
import xtable.Yybfushi;

public class GM_bitcoinbalance extends GMCommand {
    boolean exec(String[] args) {
        try {
            final long roleid;
            if (args.length >= 1) {
                roleid = Long.valueOf(args[0]);
            } else {
                roleid = this.getGmroleid();
            }

            (new Procedure() {
                protected boolean process() {
                    try {
                        Pack bag = new Pack(roleid, false);
                        CurrencyBalance balance = GM_bitcoinbalance.this.queryCurrencyBalance(bag, roleid);
                        GM_bitcoinbalance.this.sendBalanceInfo(roleid, balance);
                        return true;
                    } catch (Exception e) {
                        GM_bitcoinbalance.this.sendToGM("查询余额失败：" + e.getMessage());
                        return false;
                    }
                }
            }).submit();
            return true;
        } catch (NumberFormatException var4) {
            this.sendToGM("参数格式错误：角色ID必须是数字");
            return false;
        } catch (Exception e) {
            this.sendToGM("查询失败：" + e.getMessage());
            return false;
        }
    }

    private CurrencyBalance queryCurrencyBalance(Pack bag, long roleid) {
        CurrencyBalance balance = new CurrencyBalance();

        try {
            balance.bitcoin = this.getCurrencyBalance(bag, 18);
            balance.cash = this.getCurrencyBalance(bag, 4);
            balance.qian = this.getQianBalance(roleid);
            balance.gold = this.getCurrencyBalance(bag, 2);
            balance.money = this.getCurrencyBalance(bag, 1);
        } catch (Exception e) {
            System.err.println("Failed to query currency balance: " + e.getMessage());
            balance.bitcoin = 0L;
            balance.cash = 0L;
            balance.qian = 0L;
            balance.gold = 0L;
            balance.money = 0L;
        }

        return balance;
    }

    private long getCurrencyBalance(Pack bag, int currencyType) {
        try {
            return bag.getCurrency(currencyType);
        } catch (Exception e) {
            System.err.println("Failed to get currency balance for type " + currencyType + ": " + e.getMessage());
            return 0L;
        }
    }

    private long getQianBalance(long roleid) {
        try {
            Integer userid = Properties.selectUserid(roleid);
            if (userid == null) {
                return 0L;
            } else {
                if (Module.getIsYYBUser(userid)) {
                    YybFushiNums yybFushiNums = Yybfushi.select(userid);
                    if (yybFushiNums != null) {
                        YybFushiNum yybFushiNum = (YybFushiNum)yybFushiNums.getRolefushi().get(roleid);
                        if (yybFushiNum != null) {
                            return (long)(yybFushiNum.getBalance() + yybFushiNum.getGenbalance());
                        }
                    }
                } else {
                    YbNums ybNums = Fushinum.select(userid);
                    if (ybNums != null) {
                        YbNum ybNum = (YbNum)ybNums.getRoleyb().get(roleid);
                        if (ybNum != null) {
                            return (long)(ybNum.getNum() + ybNum.getSysnum());
                        }
                    }
                }

                return 0L;
            }
        } catch (Exception e) {
            System.err.println("Failed to get qian balance for role " + roleid + ": " + e.getMessage());
            return 0L;
        }
    }

    private void sendBalanceInfo(long roleid, CurrencyBalance balance) {
        this.sendToGM("角色 " + roleid + " 的货币余额:");
        this.sendToGM("===============================");
        this.sendToGM(String.format("比特币 (Bitcoin): %d BTC", balance.bitcoin));
        this.sendToGM(String.format("元宝 (Cash):     %d", balance.cash));
        this.sendToGM(String.format("仙玉 (Qian):     %d", balance.qian));
        this.sendToGM(String.format("金币 (Gold):     %d", balance.gold));
        this.sendToGM(String.format("银币 (Money):    %d", balance.money));
        this.sendToGM("===============================");
        double totalBtcValue = (double)balance.bitcoin + (double)balance.cash / (double)10.0F + (double)balance.qian / (double)100.0F + (double)balance.gold / (double)1000.0F + (double)balance.money / (double)100000.0F;
        this.sendToGM(String.format("总价值 (比特币等价): %.6f BTC", totalBtcValue));
        this.sendToGM("当前汇率: 1BTC = 10元宝 = 100仙玉 = 1000金币 = 100000银币");
    }

    String usage() {
        return "bitcoinbalance [角色ID(可选)]";
    }

    private static class CurrencyBalance {
        long bitcoin;
        long cash;
        long qian;
        long gold;
        long money;

        private CurrencyBalance() {
            this.bitcoin = 0L;
            this.cash = 0L;
            this.qian = 0L;
            this.gold = 0L;
            this.money = 0L;
        }
    }
}
