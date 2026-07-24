//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.util.Misc;
import gnet.link.Onlines;
import xbean.BattleInfo;

public class PetChat {
    public static void randomPetChatAndSend(BattleInfo battle, int index, boolean self) {
        int randomChat = -1;
        if (self) {
            randomChat = Misc.getRandomBetween(0, 1);
        } else {
            randomChat = Misc.getRandomBetween(2, 3);
        }

        SPetGossip send = new SPetGossip(index, randomChat);
        Onlines.getInstance().send(battle.getRoleids().keySet(), send);
        if (Module.logger.isDebugEnabled()) {
            Module.logger.debug("Battleindex:" + index + " GossipId:" + randomChat);
        }

    }
}
