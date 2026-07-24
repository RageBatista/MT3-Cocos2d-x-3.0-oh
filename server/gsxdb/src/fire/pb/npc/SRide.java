//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SRide implements ConvMain.Checkable, Comparable<SRide> {
    public int id;
    public int ridemodel;
    public int ridebuff;

    public int compareTo(SRide var1) {
        return this.id - var1.id;
    }

    public SRide() {
        this.id = 0;
        this.ridemodel = 0;
        this.ridebuff = 0;
    }

    public SRide(SRide var1) {
        this.id = var1.id;
        this.ridemodel = var1.ridemodel;
        this.ridebuff = var1.ridebuff;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> var1) {
    }

    public int getRidemodel() {
        return this.ridemodel;
    }

    public int getRidebuff() {
        return this.ridebuff;
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public void setRidemodel(int var1) {
        this.ridemodel = var1;
    }

    public void setRidebuff(int var1) {
        this.ridebuff = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
