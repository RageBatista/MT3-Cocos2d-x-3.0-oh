//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class SDayReaward implements ConvMain.Checkable, Comparable<SDayReaward> {
    public int id = 0;
    public int item1id = 0;
    public int item1num = 0;
    public int item2id = 0;
    public int item2num = 0;
    public int item3id = 0;
    public int item3num = 0;
    public int needcapacity = 0;

    public int compareTo(SDayReaward o) {
        return this.id - o.id;
    }

    public SDayReaward() {
    }

    public SDayReaward(SDayReaward arg) {
        this.id = arg.id;
        this.item1id = arg.item1id;
        this.item1num = arg.item1num;
        this.item2id = arg.item2id;
        this.item2num = arg.item2num;
        this.item3id = arg.item3id;
        this.item3num = arg.item3num;
        this.needcapacity = arg.needcapacity;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getItem1id() {
        return this.item1id;
    }

    public void setItem1id(int v) {
        this.item1id = v;
    }

    public int getItem1num() {
        return this.item1num;
    }

    public void setItem1num(int v) {
        this.item1num = v;
    }

    public int getItem2id() {
        return this.item2id;
    }

    public void setItem2id(int v) {
        this.item2id = v;
    }

    public int getItem2num() {
        return this.item2num;
    }

    public void setItem2num(int v) {
        this.item2num = v;
    }

    public int getItem3id() {
        return this.item3id;
    }

    public void setItem3id(int v) {
        this.item3id = v;
    }

    public int getItem3num() {
        return this.item3num;
    }

    public void setItem3num(int v) {
        this.item3num = v;
    }

    public int getNeedcapacity() {
        return this.needcapacity;
    }

    public void setNeedcapacity(int v) {
        this.needcapacity = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
