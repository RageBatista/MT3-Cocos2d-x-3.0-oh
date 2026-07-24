//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ArchiveInfo implements Marshal, Comparable<ArchiveInfo> {
    public int archiveid;
    public int state;

    public ArchiveInfo() {
    }

    public ArchiveInfo(int _archiveid_, int _state_) {
        this.archiveid = _archiveid_;
        this.state = _state_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.archiveid);
        _os_.marshal(this.state);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.archiveid = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ArchiveInfo) {
            ArchiveInfo _o_ = (ArchiveInfo)_o1_;
            if (this.archiveid != _o_.archiveid) {
                return false;
            } else {
                return this.state == _o_.state;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.archiveid;
        _h_ += this.state;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.archiveid).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ArchiveInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.archiveid - _o_.archiveid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.state - _o_.state;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
