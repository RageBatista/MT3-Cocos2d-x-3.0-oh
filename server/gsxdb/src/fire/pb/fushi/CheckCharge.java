//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import gnet.DeliveryManager;
import gnet.QueryOrderRequest;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import mkdb.Procedure;
import xbean.AppstoretidStatus;
import xbean.ChargeHistory;
import xbean.ChargeOrder;
import xtable.Appstoretidstatus;
import xtable.Chargehistory;
import xtable.Chargeorder;
import xtable.Failedchargeorder;

public class CheckCharge implements Runnable {
    private final long sn;

    public CheckCharge(long sn) {
        this.sn = sn;
    }

    public void run() {
        (new Procedure() {
            protected boolean process() throws Exception {
                ChargeOrder chargeOrder = Chargeorder.get(CheckCharge.this.sn);
                if (chargeOrder == null) {
                    FushiManager.logger.info("数据库没有该单号,不再发送请求.chargeGameSn:" + CheckCharge.this.sn);
                    return true;
                } else if (chargeOrder.getRetrytimes() <= 0) {
                    FushiManager.logger.info("尝试10次,不再发送请求,放入废单队列中.chargeGameSn:" + CheckCharge.this.sn);
                    Chargeorder.remove(CheckCharge.this.sn);
                    chargeOrder.setStatus(2);
                    Failedchargeorder.insert(CheckCharge.this.sn, chargeOrder.copy());
                    ChargeHistory chargeHistory = Chargehistory.get(chargeOrder.getUserid());
                    if (chargeHistory != null) {
                        ChargeOrder chargeOrder2 = (ChargeOrder)chargeHistory.getCharges().get(CheckCharge.this.sn);
                        chargeOrder2.setStatus(2);
                    }

                    if (chargeOrder.getTranscationid() != null && chargeOrder.getTranscationid().length() > 0) {
                        AppstoretidStatus status = Appstoretidstatus.get(Long.parseLong(chargeOrder.getTranscationid()));
                        if (status != null) {
                            status.setStatus(2);
                        }
                    }

                    return true;
                } else {
                    chargeOrder.setRetrytimes(chargeOrder.getRetrytimes() - 1);
                    QueryOrderRequest queryOrderRequest = new QueryOrderRequest();
                    queryOrderRequest.platid = chargeOrder.getPlattype();
                    queryOrderRequest.orderserialgame = String.valueOf(CheckCharge.this.sn);
                    this.handleSpecialPlat(queryOrderRequest, chargeOrder);
                    DeliveryManager.getInstance().send(queryOrderRequest);
                    FushiManager.logger.info("重新发送轮询充值请求.chargeGameSn Or transcationid:" + queryOrderRequest.orderserialgame + "remain times:" + chargeOrder.getRetrytimes());
                    Executor.getInstance().schedule(new CheckCharge(CheckCharge.this.sn), (long)((double)30.0F * Math.pow((double)2.0F, (double)(10 - chargeOrder.getRetrytimes()))), TimeUnit.SECONDS);
                    return true;
                }
            }

            private void handleSpecialPlat(QueryOrderRequest queryOrderRequest, ChargeOrder chargeOrder) {
                String platType = chargeOrder.getPlattype();
                if (chargeOrder.getTranscationid().length() > 0 && chargeOrder.getReceipt().length() > 0) {
                    queryOrderRequest.orderserialgame = chargeOrder.getTranscationid();
                    queryOrderRequest.orderserialplat = chargeOrder.getReceipt();
                }

            }
        }).submit();
    }
}
