//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.main.ConfigManager;
import fire.pb.util.DateValidate;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import org.apache.log4j.Logger;

public class SpecialVisitProcessCreator {
    private static SpecialVisitProcessCreator _instance;
    protected static final Logger logger = Logger.getLogger("MAPMAIN");
    static Map<Integer, SFestivalGift> giftConfig = ConfigManager.getInstance().getConf(SFestivalGift.class);

    private SpecialVisitProcessCreator() {
    }

    public static SpecialVisitProcessCreator getInstance() {
        synchronized(SpecialVisitProcessCreator.class) {
            if (null == _instance) {
                _instance = new SpecialVisitProcessCreator();
            }

            return _instance;
        }
    }

    public void transFestivalGift(Map<Integer, Integer> config) {
        for(SFestivalGift current : giftConfig.values()) {
            Integer time = null;

            try {
                time = this.getDayByLongTime(current.getTime());
            } catch (Exception e) {
                e.printStackTrace();
                logger.error("节日礼物时间转换的时候出错：  ", e);
                continue;
            }

            config.put(time, current.getId());
        }

    }

    private Integer getDayByLongTime(String time) throws Exception {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate = sdf.parse(time);
        return (int)((startDate.getTime() + DateValidate.TIME_ZONE_OFFSET) / 86400000L);
    }

    public SpecialNpcDialogProcessor createNpcDialogProcessor(long roleid, long npcKey) {
        SpecialNpcDialogProcessor processor = null;
        return processor;
    }
}
