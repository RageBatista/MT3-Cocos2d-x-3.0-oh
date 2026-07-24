//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetSkillCertificationLingWu extends __CPetSkillCertificationLingWu__ {
    public static final int PROTOCOL_TYPE = 817965;
    public int petkey;
    public int skillid;
    public int isconfirm;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetSkillCertificationLingWu proc = new PPetSkillCertificationLingWu(roleid, this.petkey, this.skillid, this.isconfirm);
            proc.submit();
        }
    }

    public int getType() {
        return 817965;
    }

    public CPetSkillCertificationLingWu() {
    }

    public CPetSkillCertificationLingWu(int _petkey_, int _skillid_, int _isconfirm_) {
        this.petkey = _petkey_;
        this.skillid = _skillid_;
        this.isconfirm = _isconfirm_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else if (this.skillid < 1) {
            return false;
        } else {
            return this.isconfirm >= 0 && this.isconfirm <= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.skillid);
            _os_.marshal(this.isconfirm);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.skillid = _os_.unmarshal_int();
        this.isconfirm = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetSkillCertificationLingWu) {
            CPetSkillCertificationLingWu _o_ = (CPetSkillCertificationLingWu)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.skillid != _o_.skillid) {
                return false;
            } else {
                return this.isconfirm == _o_.isconfirm;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.skillid;
        _h_ += this.isconfirm;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.skillid).append(",");
        _sb_.append(this.isconfirm).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetSkillCertificationLingWu _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.skillid - _o_.skillid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.isconfirm - _o_.isconfirm;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
