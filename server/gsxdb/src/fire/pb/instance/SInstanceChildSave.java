//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.Map;
import mytools.ConvMain;

public class SInstanceChildSave implements ConvMain.Checkable, Comparable<SInstanceChildSave> {
    public int id = 0;
    public int belongfuben = 0;
    public int belongjindu = 0;
    public int childrenjindu = 0;
    public String YNchildrenjindu = null;
    public int num = 0;
    public String eachpoint = null;
    public String finishpoint = null;

    public int compareTo(SInstanceChildSave o) {
        return this.id - o.id;
    }

    public SInstanceChildSave() {
    }

    public SInstanceChildSave(SInstanceChildSave arg) {
        this.id = arg.id;
        this.belongfuben = arg.belongfuben;
        this.belongjindu = arg.belongjindu;
        this.childrenjindu = arg.childrenjindu;
        this.YNchildrenjindu = arg.YNchildrenjindu;
        this.num = arg.num;
        this.eachpoint = arg.eachpoint;
        this.finishpoint = arg.finishpoint;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    public int getBelongjindu() {
        return this.belongjindu;
    }

    public void setBelongjindu(int v) {
        this.belongjindu = v;
    }

    public int getChildrenjindu() {
        return this.childrenjindu;
    }

    public void setChildrenjindu(int v) {
        this.childrenjindu = v;
    }

    public String getYNchildrenjindu() {
        return this.YNchildrenjindu;
    }

    public void setYNchildrenjindu(String v) {
        this.YNchildrenjindu = v;
    }

    public int getNum() {
        return this.num;
    }

    public void setNum(int v) {
        this.num = v;
    }

    public String getEachpoint() {
        return this.eachpoint;
    }

    public void setEachpoint(String v) {
        this.eachpoint = v;
    }

    public String getFinishpoint() {
        return this.finishpoint;
    }

    public void setFinishpoint(String v) {
        this.finishpoint = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
