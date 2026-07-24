//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.product;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.SFenJie;
import fire.pb.main.ConfigManager;
import gnet.link.Onlines;
import mkdb.Procedure;

public class CZaHuoFenJie extends __CZaHuoFenJie__ {
    public static final int PROTOCOL_TYPE = 800017;
    public int itemkey;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            (new Procedure() {
                public boolean process() {
                    Pack bag = new Pack(roleid, false);
                    ItemBase bi = bag.getItem(CZaHuoFenJie.this.itemkey);
                    if (bi == null) {
                        return false;
                    } else {
                        SFenJie sFenJie = (SFenJie)ConfigManager.getInstance().getConf(SFenJie.class).get(bi.getItemId());
                        if (sFenJie == null) {
                            return false;
                        } else if (bag.removeItemWithKey(CZaHuoFenJie.this.itemkey, 1, YYLoggerTuJingEnum.tujing_Value_fenjie, 0, "杂货分解") == 0) {
                            return false;
                        } else {
                            return bag.addItem(sFenJie.returnitemid, sFenJie.returnitemnum, "杂货分解", YYLoggerTuJingEnum.GM, 0, true) != 0;
                        }
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 800017;
    }

    public CZaHuoFenJie() {
    }

    public CZaHuoFenJie(int _itemkey_) {
        this.itemkey = _itemkey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.itemkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
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
        } else if (_o1_ instanceof CZaHuoFenJie) {
            CZaHuoFenJie _o_ = (CZaHuoFenJie)_o1_;
            return this.itemkey == _o_.itemkey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CZaHuoFenJie _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemkey - _o_.itemkey;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
