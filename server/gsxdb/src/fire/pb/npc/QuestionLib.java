//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.mission.Squestions;
import fire.pb.util.Misc;
import java.util.HashMap;
import java.util.Map;

public class QuestionLib {
    public final int libId;
    public final Map<Integer, Squestions> questions = new HashMap();

    QuestionLib(int libId) {
        this.libId = libId;
    }

    public Squestions randomQuestion() {
        return (Squestions)Misc.getRandom(this.questions.values());
    }
}
