//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import fire.pb.main.ConfigManager;
import fire.pb.main.ModuleInterface;
import fire.pb.main.ReloadResult;
import fire.pb.shop.srv.Shop;
import fire.pb.shop.srv.floating.FileterFloatingShop;
import fire.pb.shop.srv.floating.FloatingOneManager;
import fire.pb.shop.srv.floating.FloatingShopPriceTask;
import fire.pb.shop.srv.market.MarketManager;
import fire.pb.shop.srv.market.floating.FloatingMarketManager;
import fire.pb.shop.srv.market.jdbc.MarketDAO;
import fire.pb.shop.utils.MarketUtils;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import mkdb.Procedure;

public class Module implements ModuleInterface {
    public static Map<Integer, MarketThreeTable> marketThreeTableMap = null;
    public static Map<Integer, SGoods> sGoodsMap = null;
    public static Map<Integer, SMallShop> sMallShopMap = null;
    public static Map<Integer, SNpcSale> sNpcSaleMap = null;
    public static Map<Integer, MarketFirstTable> marketFirstTableMap = null;

    public void exit() {
    }

    public void init() throws Exception {
        MarketDAO.getInstance().createTable();
        (new Procedure() {
            protected boolean process() throws Exception {
                return MarketDAO.getInstance().initializationDataFromXdb();
            }
        }).submit();
        if (Shop.LOG.isDebugEnabled()) {
            Shop.LOG.debug("shop价格统计模块加载开始");
        }

        Procedure.execute(new InitStatisticsOneData(), new InitStatisticsOneDone());
        if (MarketManager.LOG.isDebugEnabled()) {
            MarketManager.LOG.debug("摆摊价格统计模块加载开始");
        }

        Procedure.execute(new InitStatisticsMarketData(), new InitStatisticsMarketDone());
    }

    public ReloadResult reload() throws Exception {
        return null;
    }

    static {
        if (!MarketUtils.isPayService()) {
            marketThreeTableMap = ConfigManager.getInstance().getConf(MarketThreeTable.class);
            sGoodsMap = ConfigManager.getInstance().getConf(SGoods.class);
            sMallShopMap = ConfigManager.getInstance().getConf(SMallShop.class);
            sNpcSaleMap = ConfigManager.getInstance().getConf(SNpcSale.class);
            marketFirstTableMap = ConfigManager.getInstance().getConf(MarketFirstTable.class);
        } else {
            Map<Integer, DMarketThreeTable> dMarketThreeTableMap = ConfigManager.getInstance().getConf(DMarketThreeTable.class);
            marketThreeTableMap = new TreeMap(dMarketThreeTableMap);
            Map<Integer, DSGoods> dSGoodsMap = ConfigManager.getInstance().getConf(DSGoods.class);
            sGoodsMap = new TreeMap(dSGoodsMap);
            Map<Integer, DSMallShop> dSMallShopMap = ConfigManager.getInstance().getConf(DSMallShop.class);
            sMallShopMap = new TreeMap(dSMallShopMap);
            Map<Integer, DSNpcSale> dSNpcSaleMap = ConfigManager.getInstance().getConf(DSNpcSale.class);
            sNpcSaleMap = new TreeMap(dSNpcSaleMap);
            Map<Integer, DMarketFirstTable> dMarketFirstTableMap = ConfigManager.getInstance().getConf(DMarketFirstTable.class);
            marketFirstTableMap = new TreeMap(dMarketFirstTableMap);
        }

    }

    class InitStatisticsOneDone implements Procedure.Done<InitStatisticsOneData> {
        public void doDone(InitStatisticsOneData p) {
            Shop.LOG.debug("shop价格统计模块加载完成");
        }
    }

    class InitStatisticsMarketDone implements Procedure.Done<InitStatisticsMarketData> {
        public void doDone(InitStatisticsMarketData p) {
            MarketManager.LOG.debug("摆摊价格统计模块加载完成");
            Executor exctor = Executor.getInstance();
            exctor.getScheduledTimeoutExecutor().setDefaultTimeout(0L);
            exctor.scheduleAtFixedRate(new FloatingShopPriceTask(), 1L, 5L, TimeUnit.SECONDS);
        }
    }

    private class InitStatisticsOneData extends Procedure {
        private InitStatisticsOneData() {
        }

        protected boolean process() throws Exception {
            for(Long shopId : FileterFloatingShop.getInstance().getFloatingOneShopIds()) {
                FloatingOneManager.getInstance().initStatisticsShopData(shopId);
            }

            return true;
        }
    }

    private class InitStatisticsMarketData extends Procedure {
        private InitStatisticsMarketData() {
        }

        protected boolean process() throws Exception {
            FloatingMarketManager.getInstance().initStatisticsMarketData();
            return true;
        }
    }
}
