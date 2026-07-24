//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SActivityAwardItems implements ConvMain.Checkable, Comparable<SActivityAwardItems> {
    public int id = 0;
    public ArrayList<Integer> items;
    public ArrayList<Integer> itemsrate;

    public int compareTo(SActivityAwardItems o) {
        return this.id - o.id;
    }

    public SActivityAwardItems() {
    }

    public SActivityAwardItems(SActivityAwardItems arg) {
        this.id = arg.id;
        this.items = arg.items;
        this.itemsrate = arg.itemsrate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getItems() {
        return this.items;
    }

    public void setItems(ArrayList<Integer> v) {
        this.items = v;
    }

    public ArrayList<Integer> getItemsrate() {
        return this.itemsrate;
    }

    public void setItemsrate(ArrayList<Integer> v) {
        this.itemsrate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
