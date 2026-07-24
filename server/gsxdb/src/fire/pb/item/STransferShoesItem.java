//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class STransferShoesItem implements ConvMain.Checkable, Comparable<STransferShoesItem> {
    public int id = 0;
    public int sceneid = 0;
    public int posx = 0;
    public int posy = 0;

    public int compareTo(STransferShoesItem o) {
        return this.id - o.id;
    }

    public STransferShoesItem() {
    }

    public STransferShoesItem(STransferShoesItem arg) {
        this.id = arg.id;
        this.sceneid = arg.sceneid;
        this.posx = arg.posx;
        this.posy = arg.posy;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSceneid() {
        return this.sceneid;
    }

    public void setSceneid(int v) {
        this.sceneid = v;
    }

    public int getPosX() {
        return this.posx;
    }

    public void setPosX(int v) {
        this.posx = v;
    }

    public int getPosY() {
        return this.posy;
    }

    public void setPosY(int v) {
        this.posy = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
