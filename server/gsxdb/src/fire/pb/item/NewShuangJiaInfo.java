//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class NewShuangJiaInfo implements Serializable {
    public long uniId;
    public HashMap<Integer, Integer> doubleadd;
    public List<Integer> lockedProp;
    public boolean lockstate = false;

    public NewShuangJiaInfo() {
        this.doubleadd = new HashMap();
        this.lockedProp = new ArrayList();
    }

    public NewShuangJiaInfo(long uniId, HashMap<Integer, Integer> doubleadd, List<Integer> lockedProp, boolean lockstate) {
        this.uniId = uniId;
        this.doubleadd = doubleadd;
        this.lockedProp = lockedProp;
        this.lockstate = lockstate;
    }

    public boolean isLockstate() {
        return this.lockstate;
    }

    public void setLockstate(boolean lockstate) {
        this.lockstate = lockstate;
    }

    public long getUniId() {
        return this.uniId;
    }

    public void setUniId(long uniId) {
        this.uniId = uniId;
    }

    public HashMap<Integer, Integer> getDoubleadd() {
        return this.doubleadd;
    }

    public void setDoubleadd(HashMap<Integer, Integer> doubleadd) {
        this.doubleadd = doubleadd;
    }
}
