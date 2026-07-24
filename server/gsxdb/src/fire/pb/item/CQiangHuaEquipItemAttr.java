//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CQiangHuaEquipItemAttr extends __CQiangHuaEquipItemAttr__ {
    public static final int PROTOCOL_TYPE = 817956;
    public int repairtype;
    public int packid;
    public int keyinpack;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            PQiangHuaEquipItemAttr pQiangHuaEquipItemAttr = new PQiangHuaEquipItemAttr(roleId, this.keyinpack, this.packid, this.repairtype);
            pQiangHuaEquipItemAttr.submit();
        }
    }

    public int getType() {
        return 817956;
    }

    public CQiangHuaEquipItemAttr() {
    }

    public CQiangHuaEquipItemAttr(int _repairtype_, int _packid_, int _keyinpack_) {
        this.repairtype = _repairtype_;
        this.packid = _packid_;
        this.keyinpack = _keyinpack_;
    }

    public final boolean _validator_() {
        if (this.repairtype >= 0 && this.repairtype <= 10) {
            if (this.packid < 1) {
                return false;
            } else {
                return this.keyinpack >= 1;
            }
        } else {
            return false;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.repairtype);
            _os_.marshal(this.packid);
            _os_.marshal(this.keyinpack);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.repairtype = _os_.unmarshal_int();
        this.packid = _os_.unmarshal_int();
        this.keyinpack = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CQiangHuaEquipItemAttr) {
            CQiangHuaEquipItemAttr _o_ = (CQiangHuaEquipItemAttr)_o1_;
            if (this.repairtype != _o_.repairtype) {
                return false;
            } else if (this.packid != _o_.packid) {
                return false;
            } else {
                return this.keyinpack == _o_.keyinpack;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.repairtype;
        _h_ += this.packid;
        _h_ += this.keyinpack;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.repairtype).append(",");
        _sb_.append(this.packid).append(",");
        _sb_.append(this.keyinpack).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CQiangHuaEquipItemAttr _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.repairtype - _o_.repairtype;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.packid - _o_.packid;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.keyinpack - _o_.keyinpack;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}
