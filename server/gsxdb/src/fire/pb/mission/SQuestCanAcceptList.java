//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;

public class SQuestCanAcceptList extends QuestCanAcceptList {
    public int compareTo(SQuestCanAcceptList o) {
        return this.id - o.id;
    }

    public SQuestCanAcceptList(QuestCanAcceptList arg) {
        super(arg);
    }

    public SQuestCanAcceptList() {
    }

    public SQuestCanAcceptList(SQuestCanAcceptList arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
