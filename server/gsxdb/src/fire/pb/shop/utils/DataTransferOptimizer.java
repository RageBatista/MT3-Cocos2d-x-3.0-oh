//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop.utils;

import fire.log.Logger;
import fire.pb.shop.Goods;
import fire.pb.shop.SResponseShopPrice;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import mkdb.Procedure;

public class DataTransferOptimizer {
    private static final Logger LOG = Logger.getLogger("DATA_TRANSFER_OPTIMIZER");
    private static final DataTransferOptimizer INSTANCE = new DataTransferOptimizer();
    private static final int DEFAULT_PAGE_SIZE = 50;
    private static final int MAX_PACKET_SIZE = 2048;
    private final ConcurrentHashMap<Long, CachedShopData> shopDataCache = new ConcurrentHashMap();

    private DataTransferOptimizer() {
        this.startCacheCleanupThread();
    }

    public static DataTransferOptimizer getInstance() {
        return INSTANCE;
    }

    public void sendOptimizedShopPrice(long roleId, long shopId, ArrayList<Goods> originalGoodsList) {
        try {
            CachedShopData cachedData = (CachedShopData)this.shopDataCache.get(shopId);
            ArrayList<Goods> goodsList;
            if (cachedData != null && !cachedData.isExpired()) {
                goodsList = cachedData.getGoodsList();
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Using cached shop data for shopId: " + shopId);
                }
            } else {
                goodsList = originalGoodsList;
                this.shopDataCache.put(shopId, new CachedShopData(shopId, originalGoodsList));
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Updated cache for shopId: " + shopId + ", items: " + originalGoodsList.size());
                }
            }

            if (goodsList.size() <= 50) {
                Procedure.psendWhileCommit(roleId, new SResponseShopPrice(shopId, goodsList));
                return;
            }

            this.sendPaginatedShopPrice(roleId, shopId, goodsList);
        } catch (Exception e) {
            LOG.error("Error in sendOptimizedShopPrice for role: " + roleId + ", shop: " + shopId, e);
            Procedure.psendWhileCommit(roleId, new SResponseShopPrice(shopId, originalGoodsList));
        }

    }

    private void sendPaginatedShopPrice(long roleId, long shopId, ArrayList<Goods> goodsList) {
        int totalItems = goodsList.size();
        int totalPages = (totalItems + 50 - 1) / 50;
        LOG.info("Sending paginated shop price data: role=" + roleId + ", shop=" + shopId + ", totalItems=" + totalItems + ", totalPages=" + totalPages);

        for(int page = 0; page < totalPages; ++page) {
            int startIndex = page * 50;
            int endIndex = Math.min(startIndex + 50, totalItems);
            ArrayList<Goods> pageGoods = new ArrayList();

            for(int i = startIndex; i < endIndex; ++i) {
                pageGoods.add(goodsList.get(i));
            }

            SResponseShopPrice response = new SResponseShopPrice(shopId, pageGoods);
            Procedure.psendWhileCommit(roleId, response);
            if (LOG.isDebugEnabled()) {
                LOG.debug("Sent page " + (page + 1) + "/" + totalPages + " for role: " + roleId + ", items: " + pageGoods.size());
            }
        }

    }

    public ArrayList<Goods> compressGoodsData(ArrayList<Goods> originalGoods) {
        ArrayList<Goods> compressedGoods = new ArrayList();

        for(Goods goods : originalGoods) {
            compressedGoods.add(goods);
        }

        return compressedGoods;
    }

    public boolean isPacketSizeExceeded(ArrayList<Goods> goodsList) {
        int estimatedSize = goodsList.size() * 50;
        return estimatedSize > 2048;
    }

    public String getCacheStats() {
        int totalCached = this.shopDataCache.size();
        int expiredCount = 0;

        for(CachedShopData data : this.shopDataCache.values()) {
            if (data.isExpired()) {
                ++expiredCount;
            }
        }

        return "Cache stats: total=" + totalCached + ", expired=" + expiredCount;
    }

    public void cleanupExpiredCache() {
        AtomicInteger cleanedCount = new AtomicInteger(0);
        this.shopDataCache.entrySet().removeIf((entry) -> {
            if (((CachedShopData)entry.getValue()).isExpired()) {
                cleanedCount.incrementAndGet();
                return true;
            } else {
                return false;
            }
        });
        if (cleanedCount.get() > 0) {
            LOG.info("Cleaned up " + cleanedCount.get() + " expired cache entries");
        }

    }

    private void startCacheCleanupThread() {
        Thread cleanupThread = new Thread(() -> {
            while(true) {
                try {
                    Thread.sleep(600000L);
                    this.cleanupExpiredCache();
                } catch (InterruptedException e) {
                    LOG.error("Cache cleanup thread interrupted", e);
                    return;
                }
            }
        });
        cleanupThread.setDaemon(true);
        cleanupThread.setName("DataTransferOptimizer-CacheCleanup");
        cleanupThread.start();
        LOG.info("DataTransferOptimizer cache cleanup thread started");
    }

    public void warmupCache(List<Long> popularShopIds) {
        LOG.info("Starting cache warmup for " + popularShopIds.size() + " shops");

        for(Long shopId : popularShopIds) {
            try {
                LOG.debug("Warmed up cache for shop: " + shopId);
            } catch (Exception e) {
                LOG.warn("Failed to warmup cache for shop: " + shopId, e);
            }
        }

        LOG.info("Cache warmup completed");
    }

    private static class CachedShopData {
        private final ArrayList<Goods> goodsList;
        private final long cacheTime;
        private final long shopId;

        public CachedShopData(long shopId, ArrayList<Goods> goodsList) {
            this.shopId = shopId;
            this.goodsList = new ArrayList(goodsList);
            this.cacheTime = System.currentTimeMillis();
        }

        public boolean isExpired() {
            return System.currentTimeMillis() - this.cacheTime > 300000L;
        }

        public ArrayList<Goods> getGoodsList() {
            return new ArrayList(this.goodsList);
        }
    }
}
