//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SRemoveTeamApply extends __SRemoveTeamApply__ {
    public static final int PROTOCOL_TYPE = 794439;
    public LinkedList<Long> applyids;

    protected void process() {
    }

    public int getType() {
        return 794439;
    }

    public SRemoveTeamApply() {
        this.applyids = new LinkedList();
    }

    public SRemoveTeamApply(LinkedList<Long> _applyids_) {
        this.applyids = _applyids_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.applyids.size());

            for(Long _v_ : this.applyids) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            long _v_ = _os_.unmarshal_long();
            this.applyids.add(_v_);
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
        } else if (_o1_ instanceof SRemoveTeamApply) {
            SRemoveTeamApply _o_ = (SRemoveTeamApply)_o1_;
            return this.applyids.equals(_o_.applyids);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.applyids.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.applyids).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
