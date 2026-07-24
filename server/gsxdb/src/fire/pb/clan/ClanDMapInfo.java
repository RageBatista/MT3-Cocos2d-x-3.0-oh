//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanDMapInfo implements Marshal, Comparable<ClanDMapInfo> {
    public int basemapid;

    public ClanDMapInfo() {
    }

    public ClanDMapInfo(int _basemapid_) {
        this.basemapid = _basemapid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.basemapid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.basemapid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanDMapInfo) {
            ClanDMapInfo _o_ = (ClanDMapInfo)_o1_;
            return this.basemapid == _o_.basemapid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.basemapid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.basemapid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ClanDMapInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.basemapid - _o_.basemapid;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
