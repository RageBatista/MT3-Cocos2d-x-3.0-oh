//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import fire.pb.main.Gs;
import mkdb.Procedure;
import org.apache.http.client.methods.HttpGet;
import xbean.YybOrder;
import xtable.Yybchargeorder;

public class CheckYybCharge implements Runnable {
    private final long chargeorder;

    public CheckYybCharge(long chargeorder) {
        this.chargeorder = chargeorder;
    }

    public void run() {
        (new Procedure() {
            protected boolean process() throws Exception {
                YybOrder yybOrder = Yybchargeorder.get(CheckYybCharge.this.chargeorder);
                if (yybOrder == null) {
                    FushiManager.logger.info("应用宝订单不存在:" + CheckYybCharge.this.chargeorder);
                    return false;
                } else if (yybOrder.getRetrytimes() <= 0) {
                    FushiManager.logger.info("应用宝订单重试次达到上限:" + CheckYybCharge.this.chargeorder);
                    FushiManager.logger.info((new StringBuilder()).append("应用宝订单失败,userid:").append(yybOrder.getUserid()).append(",roleid:").append(yybOrder.getRoleid()).append(",num:").append(yybOrder.getNum()).append(",platname:").append(yybOrder.getPlatname()));
                    pexecuteWhileCommit(new PRevertYybFushi(CheckYybCharge.this.chargeorder, yybOrder.getUserid(), yybOrder.getRoleid()));
                    return true;
                } else {
                    yybOrder.setRetrytimes(yybOrder.getRetrytimes() - 1);
                    if (yybOrder.getNum() > 0) {
                        HttpGet req = FushiManager.makeYybAddCurrencyRequest(yybOrder.getUserid(), yybOrder.getRoleid(), yybOrder.getNum(), CheckYybCharge.this.chargeorder);
                        if (req == null) {
                            FushiManager.logger.error((new StringBuilder()).append("应用宝重试订单失败,userid:").append(yybOrder.getUserid()).append(",roleid:").append(yybOrder.getRoleid()).append(",FushiManager.addFushiToUser:HttpGet is null"));
                            return false;
                        }

                        Gs.getHttpClient().execute(req, new YybAddCurrencyHandler(yybOrder.getUserid(), yybOrder.getRoleid(), CheckYybCharge.this.chargeorder) {
                            protected boolean executeHandler(int balance, int genBalance, int saveAmt) {
                                return true;
                            }
                        });
                    } else {
                        HttpGet req = FushiManager.makeYybSubCurrencyRequest(yybOrder.getUserid(), yybOrder.getRoleid(), -yybOrder.getNum(), CheckYybCharge.this.chargeorder);
                        if (req == null) {
                            FushiManager.logger.error((new StringBuilder()).append("应用宝重试订单失败,userid:").append(yybOrder.getUserid()).append(",roleid:").append(yybOrder.getRoleid()).append("FushiManager.addFushiToUser:HttpGet is null"));
                            return false;
                        }

                        Gs.getHttpClient().execute(req, new YybSubCurrencyHandler(yybOrder.getUserid(), yybOrder.getRoleid(), CheckYybCharge.this.chargeorder) {
                            protected boolean executeHandler(int balance, int genBalance, int saveAmt) {
                                return true;
                            }
                        });
                    }

                    return true;
                }
            }
        }).submit();
    }
}
