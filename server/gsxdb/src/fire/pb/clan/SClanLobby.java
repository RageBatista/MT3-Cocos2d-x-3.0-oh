//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanLobby implements ConvMain.Checkable, Comparable<SClanLobby> {
    public int id = 0;
    public int levelupcost = 0;
    public int costeveryday = 0;
    public int downcompensate = 0;
    public int othersum = 0;

    public int compareTo(SClanLobby o) {
        return this.id - o.id;
    }

    public SClanLobby() {
    }

    public SClanLobby(SClanLobby arg) {
        this.id = arg.id;
        this.levelupcost = arg.levelupcost;
        this.costeveryday = arg.costeveryday;
        this.downcompensate = arg.downcompensate;
        this.othersum = arg.othersum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevelupcost() {
        return this.levelupcost;
    }

    public void setLevelupcost(int v) {
        this.levelupcost = v;
    }

    public int getCosteveryday() {
        return this.costeveryday;
    }

    public void setCosteveryday(int v) {
        this.costeveryday = v;
    }

    public int getDowncompensate() {
        return this.downcompensate;
    }

    public void setDowncompensate(int v) {
        this.downcompensate = v;
    }

    public int getOthersum() {
        return this.othersum;
    }

    public void setOthersum(int v) {
        this.othersum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
