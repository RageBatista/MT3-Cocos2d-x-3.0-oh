//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetLearnSkillByBook extends __CPetLearnSkillByBook__ {
    public static final int PROTOCOL_TYPE = 788479;
    public int petkey;
    public int bookkey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetLearnSkillByBook proc = new PPetLearnSkillByBook(roleid, this.petkey, this.bookkey);
            proc.submit();
        }
    }

    public int getType() {
        return 788479;
    }

    public CPetLearnSkillByBook() {
    }

    public CPetLearnSkillByBook(int _petkey_, int _bookkey_) {
        this.petkey = _petkey_;
        this.bookkey = _bookkey_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.bookkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.bookkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.bookkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetLearnSkillByBook) {
            CPetLearnSkillByBook _o_ = (CPetLearnSkillByBook)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.bookkey == _o_.bookkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.bookkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.bookkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetLearnSkillByBook _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.bookkey - _o_.bookkey;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
