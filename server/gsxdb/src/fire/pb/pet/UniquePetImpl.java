//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.exception.NoSuchUniquePetException;
import xbean.PetInfo;
import xbean.UniquePet;
import xtable.Uniquepets;

public class UniquePetImpl implements IUniquePetWrap {
    UniquePet uniquePet = null;
    boolean readOnly = false;
    long uniquePetId;

    public UniquePetImpl(long uniquePetId, boolean readOnly) throws NoSuchUniquePetException {
        if (readOnly) {
            this.uniquePet = Uniquepets.select(uniquePetId);
        } else {
            this.uniquePet = Uniquepets.get(uniquePetId);
        }

        if (null == this.uniquePet) {
            throw new NoSuchUniquePetException("uniquePetId:" + uniquePetId + " Uniquepets not found!");
        } else {
            this.readOnly = readOnly;
            this.uniquePetId = uniquePetId;
        }
    }

    public Pet getPetInfo() {
        long roleId = this.uniquePet.getRoleid();
        Pet pet = this.getPetFromColumnAndDepot(roleId);
        return pet;
    }

    public Pet getPetFromMarket(long roleId) {
        PetColumn column = null;

        try {
            column = new PetColumn(roleId, 5, this.readOnly);
        } catch (Exception e) {
            e.printStackTrace();
            Module.logger.error("Error new PetColumn e:", e);
        }

        if (null != column) {
            for(PetInfo current : column.getPetsMap().values()) {
                if (this.uniquePetId == current.getUniqid()) {
                    return column.getPet(current.getKey());
                }
            }
        }

        return null;
    }

    private Pet getPetFromColumnAndDepot(long roleId) {
        PetColumn petColumn = null;

        try {
            petColumn = new PetColumn(roleId, 1, this.readOnly);
        } catch (Exception e) {
            e.printStackTrace();
            Module.logger.error("Error new PetColumn e:", e);
        }

        if (null != petColumn) {
            for(PetInfo current : petColumn.getPetsMap().values()) {
                if (this.uniquePetId == current.getUniqid()) {
                    return petColumn.getPet(current.getKey());
                }
            }
        }

        PetColumn depot = null;

        try {
            depot = new PetColumn(roleId, 2, this.readOnly);
        } catch (Exception e) {
            e.printStackTrace();
            Module.logger.error("Error new PetColumn e:", e);
        }

        if (null != depot) {
            for(PetInfo current : depot.getPetsMap().values()) {
                if (this.uniquePetId == current.getUniqid()) {
                    return depot.getPet(current.getKey());
                }
            }
        }

        return null;
    }
}
