//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PAddExpProc;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import java.util.Arrays;
import mkdb.Procedure;
import xbean.Properties;

public class PExpExchange extends Procedure {
    private long roleid;
    private long exp;
    private int itemid;
    private int itemnum;

    public PExpExchange(long roleid, long exp, int itemid, int itemnum) {
        this.roleid = roleid;
        this.exp = exp;
        this.itemid = itemid;
        this.itemnum = itemnum;
    }

    protected boolean process() throws Exception {
        Properties properties = xtable.Properties.get(this.roleid);
        if (properties == null) {
            return false;
        } else if (properties.getLevel() < 160) {
            MessageMgr.psendMsgNotifyWhileCommit(this.roleid, 191226,Arrays.<String>asList("等级不足160级！兑换失败！"));
            return false;
        } else if (properties.getExp() < this.exp) {
            MessageMgr.psendMsgNotifyWhileCommit(this.roleid, 191226,Arrays.<String>asList("经验不足20亿！兑换失败！"));
            return false;
        } else {
            boolean issuccessful = (new PAddExpProc(this.roleid, -this.exp, true, 4003, "消耗经验兑换潜能果")).call();
            if (!issuccessful) {
                return false;
            } else if (BagUtil.addItem(this.roleid, this.itemid, this.itemnum, "消耗经验兑换潜能果", YYLoggerTuJingEnum.GM, this.itemid) <= 0) {
                (new PAddExpProc(this.roleid, this.exp, true, 4003, "消耗经验兑换潜能果")).call();
                return false;
            } else {
                MessageMgr.psendMsgNotifyWhileCommit(this.roleid, 191226,Arrays.<String>asList("兑换成功！"));
                return true;
            }
        }
    }
}
