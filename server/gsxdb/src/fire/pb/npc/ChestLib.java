//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.util.Misc;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ChestLib {
    public final int libId;
    public final Map<Integer, SBaoxiang> chests = new HashMap();

    public ChestLib(int libId) {
        this.libId = libId;
    }

    public List<SBaoxiang> getRandomChests(int num, boolean canrepeat) {
        List<SBaoxiang> randomchests = new LinkedList();
        if (canrepeat) {
            for(int i = 0; i < num; ++i) {
                randomchests.add(Misc.getRandom(this.chests.values()));
            }
        } else {
            List<SBaoxiang> list = new LinkedList();
            list.addAll(this.chests.values());
            Misc.randomlizeList(list);
            int max = Math.min(num, list.size());

            for(int i = 0; i < max; ++i) {
                randomchests.add(list.get(i));
            }
        }

        return randomchests;
    }
}
