//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetExpCultivate extends __CPetExpCultivate__ {
    public static final int PROTOCOL_TYPE = 788523;
    public int petkey;
    public int itemid;
    public byte itemnum;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetExpCultivate proc = new PPetExpCultivate(roleid, this.petkey, this.itemid, this.itemnum);
            proc.submit();
        }
    }

    public int getType() {
        return 788523;
    }

    public CPetExpCultivate() {
    }

    public CPetExpCultivate(int _petkey_, int _itemid_, byte _itemnum_) {
        this.petkey = _petkey_;
        this.itemid = _itemid_;
        this.itemnum = _itemnum_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else if (this.itemid < 1) {
            return false;
        } else {
            return this.itemnum >= 1 && this.itemnum <= 10;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.itemid);
            _os_.marshal(this.itemnum);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.itemid = _os_.unmarshal_int();
        this.itemnum = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetExpCultivate) {
            CPetExpCultivate _o_ = (CPetExpCultivate)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.itemnum == _o_.itemnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.itemid;
        _h_ += this.itemnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetExpCultivate _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.itemid - _o_.itemid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.itemnum - _o_.itemnum;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
