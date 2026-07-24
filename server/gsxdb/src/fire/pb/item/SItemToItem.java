//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SItemToItem implements ConvMain.Checkable, Comparable<SItemToItem> {
    public int id = 0;
    public ArrayList<Integer> itemsid;

    public int compareTo(SItemToItem o) {
        return this.id - o.id;
    }

    public SItemToItem() {
    }

    public SItemToItem(SItemToItem arg) {
        this.id = arg.id;
        this.itemsid = arg.itemsid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getItemsid() {
        return this.itemsid;
    }

    public void setItemsid(ArrayList<Integer> v) {
        this.itemsid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
