//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;

public class SQuestCanAcceptListDianKa extends QuestCanAcceptList {
    public int compareTo(SQuestCanAcceptListDianKa o) {
        return this.id - o.id;
    }

    public SQuestCanAcceptListDianKa(QuestCanAcceptList arg) {
        super(arg);
    }

    public SQuestCanAcceptListDianKa() {
    }

    public SQuestCanAcceptListDianKa(SQuestCanAcceptListDianKa arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
