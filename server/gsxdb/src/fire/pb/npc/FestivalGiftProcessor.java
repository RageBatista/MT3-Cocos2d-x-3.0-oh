//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.main.ConfigManager;
import fire.pb.util.DateValidate;
import java.util.Map;
import xbean.FestivalGift;
import xtable.Festival;

public class FestivalGiftProcessor extends SpecialNpcDialogProcessor {
    public static final int NONE_FESTIVAL_CHAT = 143410;
    public static final int FESTIVAL_CHAT = 143411;
    static Map<Integer, SFestivalGift> giftConfig = ConfigManager.getInstance().getConf(SFestivalGift.class);

    public FestivalGiftProcessor(long roleid, long npcKey) {
        super(roleid, npcKey);
    }

    public void onVisitNpc() {
        super.onVisitNpc();
    }

    public boolean isDrawGiftAlready() {
        FestivalGift festivalGift = Festival.select(this.roleid);
        if (null == festivalGift) {
            return false;
        } else {
            return DateValidate.inTheSameDay(System.currentTimeMillis(), festivalGift.getTime());
        }
    }

    public static int getTodayFestivalID() {
        int today = (int)((System.currentTimeMillis() + DateValidate.TIME_ZONE_OFFSET) / 86400000L);
        Integer festivalID = (Integer)Module.festivalGiftConfig.get(today);
        return null == festivalID ? -1 : festivalID;
    }
}
