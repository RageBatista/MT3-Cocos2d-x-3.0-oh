//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DemoBuff implements Marshal, Comparable<DemoBuff> {
    public int fighterid;
    public int buffid;
    public int round;

    public DemoBuff() {
    }

    public DemoBuff(int _fighterid_, int _buffid_, int _round_) {
        this.fighterid = _fighterid_;
        this.buffid = _buffid_;
        this.round = _round_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.fighterid);
        _os_.marshal(this.buffid);
        _os_.marshal(this.round);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.fighterid = _os_.unmarshal_int();
        this.buffid = _os_.unmarshal_int();
        this.round = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DemoBuff) {
            DemoBuff _o_ = (DemoBuff)_o1_;
            if (this.fighterid != _o_.fighterid) {
                return false;
            } else if (this.buffid != _o_.buffid) {
                return false;
            } else {
                return this.round == _o_.round;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.fighterid;
        _h_ += this.buffid;
        _h_ += this.round;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.fighterid).append(",");
        _sb_.append(this.buffid).append(",");
        _sb_.append(this.round).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(DemoBuff _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.fighterid - _o_.fighterid;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.buffid - _o_.buffid;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.round - _o_.round;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}
