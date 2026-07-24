//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInstanceService implements ConvMain.Checkable, Comparable<SInstanceService> {
    public int id = 0;
    public String name = null;
    public int belongfuben = 0;
    public int friststate = 0;
    public ArrayList<String> changestate;

    public int compareTo(SInstanceService o) {
        return this.id - o.id;
    }

    public SInstanceService() {
    }

    public SInstanceService(SInstanceService arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.belongfuben = arg.belongfuben;
        this.friststate = arg.friststate;
        this.changestate = arg.changestate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    public int getFriststate() {
        return this.friststate;
    }

    public void setFriststate(int v) {
        this.friststate = v;
    }

    public ArrayList<String> getChangestate() {
        return this.changestate;
    }

    public void setChangestate(ArrayList<String> v) {
        this.changestate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
