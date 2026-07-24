/*
 * @作者：kevinsuperme kevinsuperme@users.noreply.github.com
 * @日期：2026-01-13 15:44:25
 * @LastEditors：kevinsuperme kevinsuperme@users.noreply.github.com
 * @LastEditTime: 2026-01-13 16:50:02
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\activity\award\PSendRankReward.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.activity.award;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.game.Srankaward;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.util.BagUtil;
import fire.pb.util.MessageUtil;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import mkdb.Procedure;
import xbean.RoleZongheRankList;
import xbean.RoleZongheRankRecord;
import xtable.Rolezonghelist;

public class PSendRankReward extends Procedure {
    public PSendRankReward() {
    }

    public boolean process() {
        RoleZongheRankList list = Rolezonghelist.select(1);
        if (list == null) {
            return true;
        } else {
            int count = 0;

            for(Iterator recordIterator = list.getRecords().iterator(); recordIterator.hasNext(); ++count) {
                RoleZongheRankRecord record = (RoleZongheRankRecord)recordIterator.next();
                if (count >= 100) {
                    break;
                }

                Srankaward awarditem = (Srankaward)ConfigManager.getInstance().getConf(Srankaward.class).get(count + 1);
                if (awarditem == null) {
                    break;
                }

                BagUtil.addItem(record.getRoleid(), awarditem.item1id, awarditem.item1num, "七日排行榜", YYLoggerTuJingEnum.tujing_Value_fubenjiangli, awarditem.item1id);
                BagUtil.addItem(record.getRoleid(), awarditem.item2id, awarditem.item2num, "七日排行榜", YYLoggerTuJingEnum.tujing_Value_fubenjiangli, awarditem.item2id);
                BagUtil.addItem(record.getRoleid(), awarditem.item3id, awarditem.item3num, "七日排行榜", YYLoggerTuJingEnum.tujing_Value_fubenjiangli, awarditem.item3id);
                MessageMgr.psendSystemMessageToRole(record.getRoleid(), 191287, (List)null);
                List<String> paras = new ArrayList();
                PropRole pRole = new PropRole(record.getRoleid(), true);
                paras.add(pRole.getName());
                paras.add(Integer.toString(count + 1));
                paras.addAll(MessageUtil.getItemMsgParas(awarditem.item1id, awarditem.item1num));
                paras.addAll(MessageUtil.getItemMsgParas(awarditem.item2id, awarditem.item2num));
                paras.addAll(MessageUtil.getItemMsgParas(awarditem.item3id, awarditem.item3num));
                STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191288, 0, paras);
                SceneManager.sendAll(ssmn);
            }

            return true;
        }
    }
}
