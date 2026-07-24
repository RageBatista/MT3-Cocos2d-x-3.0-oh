//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class FindTreasureResult implements ConvMain.Checkable {
    public int id = 0;
    public int itemId = 0;
    public String awardId = null;
    public int group = 0;
    public int minlevel = 0;
    public int maxlevel = 0;

    public FindTreasureResult() {
    }

    public FindTreasureResult(FindTreasureResult arg) {
        this.id = arg.id;
        this.itemId = arg.itemId;
        this.awardId = arg.awardId;
        this.group = arg.group;
        this.minlevel = arg.minlevel;
        this.maxlevel = arg.maxlevel;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getItemId() {
        return this.itemId;
    }

    public void setItemId(int v) {
        this.itemId = v;
    }

    public String getAwardId() {
        return this.awardId;
    }

    public void setAwardId(String v) {
        this.awardId = v;
    }

    public int getGroup() {
        return this.group;
    }

    public void setGroup(int v) {
        this.group = v;
    }

    public int getMinlevel() {
        return this.minlevel;
    }

    public void setMinlevel(int v) {
        this.minlevel = v;
    }

    public int getMaxlevel() {
        return this.maxlevel;
    }

    public void setMaxlevel(int v) {
        this.maxlevel = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
