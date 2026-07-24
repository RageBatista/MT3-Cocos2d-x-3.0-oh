//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;

public class PGotoTeamLeader extends Procedure {
    private final Team team;
    private final long memberroleid;
    private final int delay;

    public PGotoTeamLeader(Team team, long memberroleid, int delay) {
        this.team = team;
        this.memberroleid = memberroleid;
        this.delay = delay;
    }

    protected boolean process() throws Exception {
        int ret = TeamManager.getInstance().execGotoLeader(this.memberroleid, this.team, true, this.delay);
        if (ret == 0) {
            Properties p = xtable.Properties.select(this.memberroleid);
            List<String> params = new ArrayList();
            params.add(p.getRolename());
            MessageMgr.sendMsgNotify(this.team.getTeamLeaderId(), 160196, params);
        }

        return true;
    }
}
