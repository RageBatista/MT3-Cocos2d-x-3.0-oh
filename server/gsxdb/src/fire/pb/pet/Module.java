//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.main.ModuleInterface;
import fire.pb.main.ReloadResult;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Set;
import mkdb.Procedure;
import mkdb.TTable;
import mkdb.Transaction;
import org.apache.log4j.Logger;
import xbean.DiscardPet;
import xtable.Petrecyclebin;

public class Module implements ModuleInterface {
    public static final Logger logger = Logger.getLogger("PET");
    private PetManager petManager = null;
    private static Module module = null;
    public static String PET_AUTOKEY_NAME = "PET_UID";
    public static final int OUTTIME_OF_PET = 60;

    public PetManager getPetManager() {
        return this.petManager;
    }

    public Module() {
        module = this;
    }

    public static Module getInstance() {
        return module;
    }

    public void exit() {
    }

    public void init() throws Exception {
        logger.info("Pet module init start");
        this.petManager = PetManager.getInstance();
        cleanPetRecycleBin();
        logger.info("Pet module init end");
    }

    public int getPetTakeLevel(int petId) {
        PetAttr attr = this.petManager.getAttr(petId);
        return attr != null ? attr.takelevel : 0;
    }

    public String getPetColorRGB(int colour) {
        return "fffcfbfb";
    }

    public static void cleanPetRecycleBin() {
        final Set<Long> toRemove = new HashSet();
        final Calendar date = Calendar.getInstance();
        date.add(10, -1440);
        Petrecyclebin.getTable().walk(new TTable.IWalk<Long, DiscardPet>() {
            public boolean onRecord(Long key, DiscardPet value) {
                if (value.getDeletedate() < date.getTimeInMillis()) {
                    toRemove.add(key);
                }

                return true;
            }
        });
        logger.info("宠物回收站删除 " + toRemove.size() + " 个过期宠物");
        Procedure proc = new Procedure() {
            protected boolean process() {
                for(Long key : toRemove) {
                    Petrecyclebin.remove(key);
                }

                return true;
            }
        };
        if (Transaction.current() == null) {
            proc.submit();
        } else {
            Procedure.pexecute(proc);
        }

    }

    public ReloadResult reload() throws Exception {
        return new ReloadResult(false, "module" + this.getClass().getName() + "not support reload");
    }
}
