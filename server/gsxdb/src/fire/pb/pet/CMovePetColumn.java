//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.npc.NpcServiceManager;
import gnet.link.Onlines;

public class CMovePetColumn extends __CMovePetColumn__ {
    public static final int PROTOCOL_TYPE = 788448;
    public int srccolumnid;
    public int petkey;
    public int dstcolumnid;
    public long npckey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (NpcServiceManager.getInstance().hasServiceByNpcKey(roleid, this.npckey, new int[]{100012})) {
                if (this.srccolumnid != 1 || Pet.isInBattle(roleid, this.petkey)) {
                    PMovePet proc = new PMovePet(this.srccolumnid, this.petkey, this.dstcolumnid, this.npckey, roleid);
                    proc.submit();
                }
            }
        }
    }

    public int getType() {
        return 788448;
    }

    public CMovePetColumn() {
    }

    public CMovePetColumn(int _srccolumnid_, int _petkey_, int _dstcolumnid_, long _npckey_) {
        this.srccolumnid = _srccolumnid_;
        this.petkey = _petkey_;
        this.dstcolumnid = _dstcolumnid_;
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        if (this.srccolumnid >= 1 && this.srccolumnid <= 2) {
            if (this.petkey < 1) {
                return false;
            } else if (this.dstcolumnid >= 1 && this.dstcolumnid <= 2) {
                return this.npckey >= 1L;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.srccolumnid);
            _os_.marshal(this.petkey);
            _os_.marshal(this.dstcolumnid);
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.srccolumnid = _os_.unmarshal_int();
        this.petkey = _os_.unmarshal_int();
        this.dstcolumnid = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CMovePetColumn) {
            CMovePetColumn _o_ = (CMovePetColumn)_o1_;
            if (this.srccolumnid != _o_.srccolumnid) {
                return false;
            } else if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.dstcolumnid != _o_.dstcolumnid) {
                return false;
            } else {
                return this.npckey == _o_.npckey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.srccolumnid;
        _h_ += this.petkey;
        _h_ += this.dstcolumnid;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.srccolumnid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.dstcolumnid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CMovePetColumn _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.srccolumnid - _o_.srccolumnid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.petkey - _o_.petkey;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.dstcolumnid - _o_.dstcolumnid;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = Long.signum(this.npckey - _o_.npckey);
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
