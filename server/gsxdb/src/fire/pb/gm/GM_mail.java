/*
 * @作者：kevinsuperme kevinsuperme@users.noreply.github.com
 * @日期：2026-01-13 15:44:25
 * @LastEditors：kevinsuperme kevinsuperme@users.noreply.github.com
 * @LastEditTime: 2026-01-13 16:46:23
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\gm\GM_mail.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.compensation.CreateSingleCompensation;
import java.util.LinkedList;
import xbean.Pod;
import xbean.SingleCompensationAward;

public class GM_mail extends GMCommand {
    boolean exec(String[] args) {
        if (args.length != 5) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            long roleId = Long.parseLong(args[0]);
            String title = args[1];
            String content = args[2];
            int duration = Integer.parseInt(args[3]);
            String awardContent = args[4];
            String[] awardParts = awardContent.split(",");
            LinkedList awardList = new LinkedList();

            for(int i = 0; i < awardParts.length; ++i) {
                String[] itemParts = awardParts[i].split("\\|");
                if (itemParts.length == 2) {
                    int itemId = Integer.parseInt(itemParts[0]);
                    int itemNum = Integer.parseInt(itemParts[1]);
                    if (itemId <= 0 || itemNum <= 0) {
                        this.sendToGM("参数格式错误： 第" + (i + 1) + "个奖励 itemId:" + itemId + " itemNum:" + itemNum);
                        return false;
                    }

                    SingleCompensationAward award = Pod.newSingleCompensationAwardData();
                    switch (itemId) {
                        case 1:
                            award.setType(1);
                            award.setNum((long)itemNum);
                            break;
                        case 2:
                            award.setType(2);
                            award.setNum((long)itemNum);
                            break;
                        case 3:
                            award.setType(3);
                            award.setNum((long)itemNum);
                            break;
                        case 4:
                            award.setType(4);
                            award.setNum((long)itemNum);
                            break;
                        case 5:
                            award.setType(5);
                            award.setNum((long)itemNum);
                            break;
                        default:
                            byte defaultFlag = 1;
                            award.setType(0);
                            award.setId((long)itemId);
                            award.setNum((long)itemNum);
                            award.setFlag((long)defaultFlag);
                    }

                    awardList.add(award);
                }
            }

            long expireTime = 0L;
            if (duration > 0) {
                expireTime = System.currentTimeMillis() + (long)(duration * 60 * 1000);
            }

            CreateSingleCompensation.createFromYunYing(roleId, awardList, title, content, expireTime, "GMOPID", "GMSIGN").submit();
            return true;
        }
    }

    String usage() {
        return "//mail roleid title content duration awardContent:1|100,2|100";
    }
}
