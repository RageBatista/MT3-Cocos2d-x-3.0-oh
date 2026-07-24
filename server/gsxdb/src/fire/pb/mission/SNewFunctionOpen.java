//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SNewFunctionOpen implements ConvMain.Checkable, Comparable<SNewFunctionOpen> {
    public int id = 0;
    public int lvtrig = 0;
    public String taskfinish = null;
    public int triggertask = 0;

    public int compareTo(SNewFunctionOpen o) {
        return this.id - o.id;
    }

    public SNewFunctionOpen() {
    }

    public SNewFunctionOpen(SNewFunctionOpen arg) {
        this.id = arg.id;
        this.lvtrig = arg.lvtrig;
        this.taskfinish = arg.taskfinish;
        this.triggertask = arg.triggertask;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLvtrig() {
        return this.lvtrig;
    }

    public void setLvtrig(int v) {
        this.lvtrig = v;
    }

    public String getTaskfinish() {
        return this.taskfinish;
    }

    public void setTaskfinish(String v) {
        this.taskfinish = v;
    }

    public int getTriggertask() {
        return this.triggertask;
    }

    public void setTriggertask(int v) {
        this.triggertask = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
