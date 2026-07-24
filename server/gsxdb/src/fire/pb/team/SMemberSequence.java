//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SMemberSequence extends __SMemberSequence__ {
    public static final int PROTOCOL_TYPE = 794467;
    public LinkedList<Long> teammemeberlist;

    protected void process() {
    }

    public int getType() {
        return 794467;
    }

    public SMemberSequence() {
        this.teammemeberlist = new LinkedList();
    }

    public SMemberSequence(LinkedList<Long> _teammemeberlist_) {
        this.teammemeberlist = _teammemeberlist_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.teammemeberlist.size());

            for(Long _v_ : this.teammemeberlist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            long _v_ = _os_.unmarshal_long();
            this.teammemeberlist.add(_v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SMemberSequence) {
            SMemberSequence _o_ = (SMemberSequence)_o1_;
            return this.teammemeberlist.equals(_o_.teammemeberlist);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.teammemeberlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teammemeberlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
