//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class FindTreasureGift implements ConvMain.Checkable {
    public int id = 0;
    public int awardId = 0;
    public int mapId = 0;
    public String itemList = null;
    public String awardids = null;
    public int moneyAwardId = 0;
    public String noticeItemList = null;
    public int noticeId = 0;
    public int getItemMessageId = 0;
    public int getMoneyMessageId = 0;

    public FindTreasureGift() {
    }

    public FindTreasureGift(FindTreasureGift arg) {
        this.id = arg.id;
        this.awardId = arg.awardId;
        this.mapId = arg.mapId;
        this.itemList = arg.itemList;
        this.awardids = arg.awardids;
        this.moneyAwardId = arg.moneyAwardId;
        this.noticeItemList = arg.noticeItemList;
        this.noticeId = arg.noticeId;
        this.getItemMessageId = arg.getItemMessageId;
        this.getMoneyMessageId = arg.getMoneyMessageId;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getAwardId() {
        return this.awardId;
    }

    public void setAwardId(int v) {
        this.awardId = v;
    }

    public int getMapId() {
        return this.mapId;
    }

    public void setMapId(int v) {
        this.mapId = v;
    }

    public String getItemList() {
        return this.itemList;
    }

    public void setItemList(String v) {
        this.itemList = v;
    }

    public String getAwardids() {
        return this.awardids;
    }

    public void setAwardids(String v) {
        this.awardids = v;
    }

    public int getMoneyAwardId() {
        return this.moneyAwardId;
    }

    public void setMoneyAwardId(int v) {
        this.moneyAwardId = v;
    }

    public String getNoticeItemList() {
        return this.noticeItemList;
    }

    public void setNoticeItemList(String v) {
        this.noticeItemList = v;
    }

    public int getNoticeId() {
        return this.noticeId;
    }

    public void setNoticeId(int v) {
        this.noticeId = v;
    }

    public int getGetItemMessageId() {
        return this.getItemMessageId;
    }

    public void setGetItemMessageId(int v) {
        this.getItemMessageId = v;
    }

    public int getGetMoneyMessageId() {
        return this.getMoneyMessageId;
    }

    public void setGetMoneyMessageId(int v) {
        this.getMoneyMessageId = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
