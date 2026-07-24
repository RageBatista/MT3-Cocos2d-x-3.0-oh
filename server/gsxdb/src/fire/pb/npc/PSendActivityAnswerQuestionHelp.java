//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.clan.ClanUtils;
import fire.pb.main.ConfigManager;
import fire.pb.message.SStringRes;
import fire.pb.mission.SActivityQuestion;
import fire.pb.talk.ChatChannel;
import fire.pb.talk.DisplayInfo;
import fire.pb.team.TeamManager;
import java.util.ArrayList;
import mkdb.Procedure;
import xbean.ClanInfo;
import xbean.Properties;

public class PSendActivityAnswerQuestionHelp extends Procedure {
    private final long roleid;
    private final int questionid;

    public PSendActivityAnswerQuestionHelp(long roleid, int questionid) {
        this.roleid = roleid;
        this.questionid = questionid;
    }

    protected boolean process() {
        ClanInfo clanInfo = ClanUtils.getClanInfoById(this.roleid, true);
        if (clanInfo == null) {
            return false;
        } else {
            Properties prop = xtable.Properties.select(this.roleid);
            if (prop == null) {
                return false;
            } else {
                SStringRes msg1 = (SStringRes)ConfigManager.getInstance().getConf(SStringRes.class).get(298);
                if (msg1 == null) {
                    TeamManager.logger.debug("PSendActivityAnswerQuestionHelp:找不到字符串 " + this.roleid);
                    return false;
                } else {
                    SStringRes msg2 = (SStringRes)ConfigManager.getInstance().getConf(SStringRes.class).get(299);
                    if (msg2 == null) {
                        TeamManager.logger.debug("PSendActivityAnswerQuestionHelp:找不到字符串 " + this.roleid);
                        return false;
                    } else {
                        String msgstring1 = msg1.msg;
                        String msgstring2 = msg2.msg;
                        SActivityQuestion question = (SActivityQuestion)ConfigManager.getInstance().getConf(SActivityQuestion.class).get(this.questionid);
                        msgstring1 = msgstring1.replaceAll("\\$parameter1\\$", question.question);
                        Integer q = this.questionid;
                        msgstring1 = msgstring1.replaceAll("\\$parameter2\\$", q.toString());
                        msgstring1 = msgstring1.replaceAll("\\$parameter3\\$", prop.getRolename());
                        msgstring1 = msgstring1.replaceAll("\\$parameter4\\$", String.valueOf(this.roleid));
                        msgstring1 = msgstring1.replaceAll("\\$parameter5\\$", String.valueOf(213));
                        ArrayList<DisplayInfo> showinfos = new ArrayList();
                        ChatChannel.getInstance().process(this.roleid, 4, msgstring1, msgstring2, showinfos, 1);
                        return true;
                    }
                }
            }
        }
    }
}
