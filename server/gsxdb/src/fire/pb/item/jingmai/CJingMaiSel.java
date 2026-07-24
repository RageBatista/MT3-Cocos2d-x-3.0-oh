//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.jingmai;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CJingMaiSel extends __CJingMaiSel__ {
    public static final int PROTOCOL_TYPE = 800108;
    public int idx;
    public int index;
    public int itemkey;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            PJingMaiSel repairEquip = new PJingMaiSel(roleId, this.idx, this.index, this.itemkey);
            repairEquip.submit();
        }
    }

    public int getType() {
        return 800108;
    }

    public CJingMaiSel() {
    }

    public CJingMaiSel(int _idx_, int _index_, int _itemkey_) {
        this.idx = _idx_;
        this.index = _index_;
        this.itemkey = _itemkey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.idx);
            _os_.marshal(this.index);
            _os_.marshal(this.itemkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.idx = _os_.unmarshal_int();
        this.index = _os_.unmarshal_int();
        this.itemkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CJingMaiSel) {
            CJingMaiSel _o_ = (CJingMaiSel)_o1_;
            if (this.idx != _o_.idx) {
                return false;
            } else if (this.index != _o_.index) {
                return false;
            } else {
                return this.itemkey == _o_.itemkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.idx;
        _h_ += this.index;
        _h_ += this.itemkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.idx).append(",");
        _sb_.append(this.index).append(",");
        _sb_.append(this.itemkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
