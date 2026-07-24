//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.common.SCommon;
import fire.pb.main.ConfigManager;
import fire.pb.mission.SActivityQuestion;
import fire.pb.mission.Squestions;
import java.util.HashMap;
import java.util.Map;

public class QuestionManager {
    public static int ActivityAnswerQuestionNum = 10;
    public static int ActivityQuestionRewardNum = 5;
    private static final QuestionManager _instance = new QuestionManager();
    private Map<Integer, QuestionLib> libs = new HashMap();
    public Map<Integer, SActivityQuestion> activityquestions = new HashMap();
    public int[] activityquestionids;
    private Map<Integer, Squestions> allquestion;
    private int ActivityQuestionNum;

    public static QuestionManager getInstance() {
        return _instance;
    }

    private QuestionManager() {
    }

    public void init() {
        this.allquestion = ConfigManager.getInstance().getConf(Squestions.class);

        for(Squestions squestion : this.allquestion.values()) {
            QuestionLib lib = (QuestionLib)this.libs.get(squestion.questionsid);
            if (lib == null) {
                lib = new QuestionLib(squestion.questionsid);
                this.libs.put(lib.libId, lib);
            }

            lib.questions.put(squestion.id, squestion);
        }

        Map<Integer, SActivityQuestion> questions = ConfigManager.getInstance().getConf(SActivityQuestion.class);
        this.ActivityQuestionNum = 0;

        for(SActivityQuestion question : questions.values()) {
            if (question.step == 0) {
                ++this.ActivityQuestionNum;
                this.activityquestions.put(question.id, question);
            }
        }

        this.activityquestionids = new int[this.ActivityQuestionNum];
        int count = 0;

        for(Integer id : this.activityquestions.keySet()) {
            this.activityquestionids[count] = id;
            ++count;
        }

        SCommon c1 = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(224);
        if (c1 != null) {
            ActivityAnswerQuestionNum = Integer.parseInt(c1.getValue());
        }

        SCommon c2 = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(235);
        if (c2 != null) {
            ActivityQuestionRewardNum = Integer.parseInt(c2.getValue());
        }

    }

    public int GetActivityQuestionNum() {
        return this.ActivityQuestionNum;
    }

    public Map<Integer, QuestionLib> getQuestionLibs() {
        return this.libs;
    }

    public Map<Integer, Squestions> getAllQuestions() {
        return this.allquestion;
    }
}
