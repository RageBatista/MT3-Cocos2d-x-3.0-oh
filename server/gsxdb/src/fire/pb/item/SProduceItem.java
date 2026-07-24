//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SProduceItem implements ConvMain.Checkable, Comparable<SProduceItem> {
    public int id = 0;
    public int level = 0;
    public ArrayList<Integer> itemList;
    public ArrayList<Integer> itemNumList;
    public ArrayList<Integer> resultItem;
    public ArrayList<Integer> resultItemRate;
    public int money = 0;
    public int itemNotEnoughMsg = 0;
    public int notice = 0;

    public int compareTo(SProduceItem o) {
        return this.id - o.id;
    }

    public SProduceItem() {
    }

    public SProduceItem(SProduceItem arg) {
        this.id = arg.id;
        this.level = arg.level;
        this.itemList = arg.itemList;
        this.itemNumList = arg.itemNumList;
        this.resultItem = arg.resultItem;
        this.resultItemRate = arg.resultItemRate;
        this.money = arg.money;
        this.itemNotEnoughMsg = arg.itemNotEnoughMsg;
        this.notice = arg.notice;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public ArrayList<Integer> getItemList() {
        return this.itemList;
    }

    public void setItemList(ArrayList<Integer> v) {
        this.itemList = v;
    }

    public ArrayList<Integer> getItemNumList() {
        return this.itemNumList;
    }

    public void setItemNumList(ArrayList<Integer> v) {
        this.itemNumList = v;
    }

    public ArrayList<Integer> getResultItem() {
        return this.resultItem;
    }

    public void setResultItem(ArrayList<Integer> v) {
        this.resultItem = v;
    }

    public ArrayList<Integer> getResultItemRate() {
        return this.resultItemRate;
    }

    public void setResultItemRate(ArrayList<Integer> v) {
        this.resultItemRate = v;
    }

    public int getMoney() {
        return this.money;
    }

    public void setMoney(int v) {
        this.money = v;
    }

    public int getItemNotEnoughMsg() {
        return this.itemNotEnoughMsg;
    }

    public void setItemNotEnoughMsg(int v) {
        this.itemNotEnoughMsg = v;
    }

    public int getNotice() {
        return this.notice;
    }

    public void setNotice(int v) {
        this.notice = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
