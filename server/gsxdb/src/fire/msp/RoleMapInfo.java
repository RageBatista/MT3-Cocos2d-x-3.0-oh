//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleMapInfo implements Marshal, Comparable<RoleMapInfo> {
    public long sceneid;
    public int posx;
    public int posy;
    public int posz;

    public RoleMapInfo() {
    }

    public RoleMapInfo(long _sceneid_, int _posx_, int _posy_, int _posz_) {
        this.sceneid = _sceneid_;
        this.posx = _posx_;
        this.posy = _posy_;
        this.posz = _posz_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.sceneid);
        _os_.marshal(this.posx);
        _os_.marshal(this.posy);
        _os_.marshal(this.posz);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.sceneid = _os_.unmarshal_long();
        this.posx = _os_.unmarshal_int();
        this.posy = _os_.unmarshal_int();
        this.posz = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleMapInfo) {
            RoleMapInfo _o_ = (RoleMapInfo)_o1_;
            if (this.sceneid != _o_.sceneid) {
                return false;
            } else if (this.posx != _o_.posx) {
                return false;
            } else if (this.posy != _o_.posy) {
                return false;
            } else {
                return this.posz == _o_.posz;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.sceneid;
        _h_ += this.posx;
        _h_ += this.posy;
        _h_ += this.posz;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.sceneid).append(",");
        _sb_.append(this.posx).append(",");
        _sb_.append(this.posy).append(",");
        _sb_.append(this.posz).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(RoleMapInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = Long.signum(this.sceneid - _o_.sceneid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.posx - _o_.posx;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.posy - _o_.posy;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.posz - _o_.posz;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
