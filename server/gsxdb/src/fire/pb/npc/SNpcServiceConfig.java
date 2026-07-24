//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SNpcServiceConfig implements ConvMain.Checkable, Comparable<SNpcServiceConfig> {
    public int id = 0;
    public ArrayList<Integer> services;

    public int compareTo(SNpcServiceConfig o) {
        return this.id - o.id;
    }

    public SNpcServiceConfig() {
    }

    public SNpcServiceConfig(SNpcServiceConfig arg) {
        this.id = arg.id;
        this.services = arg.services;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getServices() {
        return this.services;
    }

    public void setServices(ArrayList<Integer> v) {
        this.services = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
