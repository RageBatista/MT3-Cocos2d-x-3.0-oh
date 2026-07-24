//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class QuestCanAcceptList implements ConvMain.Checkable {
    public int id = 0;
    public int 任务等级min = 0;
    public int 任务等级max = 0;

    public QuestCanAcceptList() {
    }

    public QuestCanAcceptList(QuestCanAcceptList arg) {
        this.id = arg.id;
        this.任务等级min = arg.任务等级min;
        this.任务等级max = arg.任务等级max;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int get任务等级min() {
        return this.任务等级min;
    }

    public void set任务等级min(int v) {
        this.任务等级min = v;
    }

    public int get任务等级max() {
        return this.任务等级max;
    }

    public void set任务等级max(int v) {
        this.任务等级max = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
