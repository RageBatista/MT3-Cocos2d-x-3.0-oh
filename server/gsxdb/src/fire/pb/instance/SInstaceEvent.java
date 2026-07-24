//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.Map;
import mytools.ConvMain;

public class SInstaceEvent implements ConvMain.Checkable, Comparable<SInstaceEvent> {
    public int id = 0;
    public String name = null;
    public int type = 0;
    public String thingcondition = null;
    public int belongfuben = 0;
    public String thingresult = null;
    public String point = null;

    public int compareTo(SInstaceEvent o) {
        return this.id - o.id;
    }

    public SInstaceEvent() {
    }

    public SInstaceEvent(SInstaceEvent arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.type = arg.type;
        this.thingcondition = arg.thingcondition;
        this.belongfuben = arg.belongfuben;
        this.thingresult = arg.thingresult;
        this.point = arg.point;
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

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public String getThingcondition() {
        return this.thingcondition;
    }

    public void setThingcondition(String v) {
        this.thingcondition = v;
    }

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    public String getThingresult() {
        return this.thingresult;
    }

    public void setThingresult(String v) {
        this.thingresult = v;
    }

    public String getPoint() {
        return this.point;
    }

    public void setPoint(String v) {
        this.point = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
