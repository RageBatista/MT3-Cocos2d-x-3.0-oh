//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.main.ConfigManager;
import java.util.HashMap;
import java.util.Map;

public class ChestManager {
    private static final ChestManager _instance = new ChestManager();
    private Map<Integer, ChestLib> libs = new HashMap();
    public Map<Integer, SBaoxiang> chests;

    public static ChestManager getInstance() {
        return _instance;
    }

    private ChestManager() {
    }

    public void init() {
        this.chests = ConfigManager.getInstance().getConf(SBaoxiang.class);

        for(SBaoxiang chest : this.chests.values()) {
            ChestLib lib = (ChestLib)this.libs.get(chest.getBaoxianglist());
            if (lib == null) {
                lib = new ChestLib(chest.getBaoxianglist());
                this.libs.put(lib.libId, lib);
            }

            lib.chests.put(chest.id, chest);
        }

    }

    public ChestLib getChestLib(int libid) {
        return (ChestLib)this.libs.get(libid);
    }

    public SBaoxiang getChestConfig(int chestid) {
        return (SBaoxiang)this.chests.get(chestid);
    }
}
