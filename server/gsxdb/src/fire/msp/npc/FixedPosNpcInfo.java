//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FixedPosNpcInfo implements Marshal, Comparable<FixedPosNpcInfo> {
    public long scene;
    public int posx;
    public int posy;
    public int npcid;
    public long npckey;

    public FixedPosNpcInfo() {
    }

    public FixedPosNpcInfo(long _scene_, int _posx_, int _posy_, int _npcid_, long _npckey_) {
        this.scene = _scene_;
        this.posx = _posx_;
        this.posy = _posy_;
        this.npcid = _npcid_;
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.scene);
        _os_.marshal(this.posx);
        _os_.marshal(this.posy);
        _os_.marshal(this.npcid);
        _os_.marshal(this.npckey);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.scene = _os_.unmarshal_long();
        this.posx = _os_.unmarshal_int();
        this.posy = _os_.unmarshal_int();
        this.npcid = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FixedPosNpcInfo) {
            FixedPosNpcInfo _o_ = (FixedPosNpcInfo)_o1_;
            if (this.scene != _o_.scene) {
                return false;
            } else if (this.posx != _o_.posx) {
                return false;
            } else if (this.posy != _o_.posy) {
                return false;
            } else if (this.npcid != _o_.npcid) {
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
        _h_ += (int)this.scene;
        _h_ += this.posx;
        _h_ += this.posy;
        _h_ += this.npcid;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.scene).append(",");
        _sb_.append(this.posx).append(",");
        _sb_.append(this.posy).append(",");
        _sb_.append(this.npcid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(FixedPosNpcInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = Long.signum(this.scene - _o_.scene);
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
                        _c_ = this.npcid - _o_.npcid;
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
}
