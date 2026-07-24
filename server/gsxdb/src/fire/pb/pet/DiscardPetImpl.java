//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.exception.NoSuchUniquePetException;
import xbean.DiscardPet;
import xbean.PetInfo;
import xtable.Petrecyclebin;

public class DiscardPetImpl implements IUniquePetWrap {
    boolean readOnly = false;
    DiscardPet discardPet = null;

    public DiscardPetImpl(long uniqueId, boolean readOnly) throws NoSuchUniquePetException {
        if (readOnly) {
            this.discardPet = Petrecyclebin.select(uniqueId);
        } else {
            this.discardPet = Petrecyclebin.get(uniqueId);
        }

        if (null == this.discardPet) {
            throw new NoSuchUniquePetException("uniqueId:" + uniqueId + " Recycle bin not found!");
        } else {
            this.readOnly = readOnly;
        }
    }

    public Pet getPetInfo() {
        PetInfo petInfo = this.discardPet.getPet();
        return Pet.getPet(petInfo);
    }
}
