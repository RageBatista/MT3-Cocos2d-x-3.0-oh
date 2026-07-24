//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SRemoveTeamMember extends __SRemoveTeamMember__ {
    public static final int PROTOCOL_TYPE = 794438;
    public LinkedList<Long> memberids;

    protected void process() {
    }

    public int getType() {
        return 794438;
    }

    public SRemoveTeamMember() {
        this.memberids = new LinkedList();
    }

    public SRemoveTeamMember(LinkedList<Long> _memberids_) {
        this.memberids = _memberids_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.memberids.size());

            for(Long _v_ : this.memberids) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            long _v_ = _os_.unmarshal_long();
            this.memberids.add(_v_);
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
        } else if (_o1_ instanceof SRemoveTeamMember) {
            SRemoveTeamMember _o_ = (SRemoveTeamMember)_o1_;
            return this.memberids.equals(_o_.memberids);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.memberids.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.memberids).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
