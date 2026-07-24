//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public abstract class __SItemBatchUse__ implements Comparable<__SItemBatchUse__> {
    public abstract int getType();

    public abstract boolean _validator_();

    public abstract OctetsStream marshal(OctetsStream var1);

    public abstract OctetsStream unmarshal(OctetsStream var1) throws MarshalException;

    public int compareTo(__SItemBatchUse__ _o_) {
        return _o_ == this ? 0 : this.getClass().getName().compareTo(_o_.getClass().getName());
    }
}
