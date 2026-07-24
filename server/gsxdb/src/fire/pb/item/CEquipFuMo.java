//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CEquipFuMo extends __CEquipFuMo__ {
    public static final int PROTOCOL_TYPE = 817954;
    public int skillid;
    public int effectid;
    public int newskillid;
    public int neweffectid;
    public int packid;
    public int keyinpack;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            PEquipFuMo pEquipFuMo = new PEquipFuMo(roleId, this.keyinpack, this.packid, this.skillid, this.effectid, this.newskillid, this.neweffectid);
            pEquipFuMo.submit();
        }
    }

    public int getType() {
        return 817954;
    }

    public CEquipFuMo() {
    }

    public CEquipFuMo(int _skillid_, int _effectid_, int _newskillid_, int _neweffectid_, int _packid_, int _keyinpack_) {
        this.skillid = _skillid_;
        this.effectid = _effectid_;
        this.newskillid = _newskillid_;
        this.neweffectid = _neweffectid_;
        this.packid = _packid_;
        this.keyinpack = _keyinpack_;
    }

    public final boolean _validator_() {
        if (this.packid < 1) {
            return false;
        } else {
            return this.keyinpack >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.skillid);
            _os_.marshal(this.effectid);
            _os_.marshal(this.newskillid);
            _os_.marshal(this.neweffectid);
            _os_.marshal(this.packid);
            _os_.marshal(this.keyinpack);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.skillid = _os_.unmarshal_int();
        this.effectid = _os_.unmarshal_int();
        this.newskillid = _os_.unmarshal_int();
        this.neweffectid = _os_.unmarshal_int();
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
        } else if (_o1_ instanceof CEquipFuMo) {
            CEquipFuMo _o_ = (CEquipFuMo)_o1_;
            if (this.skillid != _o_.skillid) {
                return false;
            } else if (this.effectid != _o_.effectid) {
                return false;
            } else if (this.newskillid != _o_.newskillid) {
                return false;
            } else if (this.neweffectid != _o_.neweffectid) {
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
        _h_ += this.skillid;
        _h_ += this.effectid;
        _h_ += this.newskillid;
        _h_ += this.neweffectid;
        _h_ += this.packid;
        _h_ += this.keyinpack;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.skillid).append(",");
        _sb_.append(this.effectid).append(",");
        _sb_.append(this.newskillid).append(",");
        _sb_.append(this.neweffectid).append(",");
        _sb_.append(this.packid).append(",");
        _sb_.append(this.keyinpack).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CEquipFuMo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.skillid - _o_.skillid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.effectid - _o_.effectid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.newskillid - _o_.newskillid;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.neweffectid - _o_.neweffectid;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.packid - _o_.packid;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.keyinpack - _o_.keyinpack;
                                return 0 != _c_ ? _c_ : _c_;
                            }
                        }
                    }
                }
            }
        }
    }
}
