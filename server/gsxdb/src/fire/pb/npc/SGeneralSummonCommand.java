//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SGeneralSummonCommand extends __SGeneralSummonCommand__ {
    public static final int PROTOCOL_TYPE = 795505;
    public int summontype;
    public long roleid;
    public long npckey;
    public int mapid;
    public int minimal;

    protected void process() {
    }

    public int getType() {
        return 795505;
    }

    public SGeneralSummonCommand() {
    }

    public SGeneralSummonCommand(int _summontype_, long _roleid_, long _npckey_, int _mapid_, int _minimal_) {
        this.summontype = _summontype_;
        this.roleid = _roleid_;
        this.npckey = _npckey_;
        this.mapid = _mapid_;
        this.minimal = _minimal_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.summontype);
            _os_.marshal(this.roleid);
            _os_.marshal(this.npckey);
            _os_.marshal(this.mapid);
            _os_.marshal(this.minimal);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.summontype = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.npckey = _os_.unmarshal_long();
        this.mapid = _os_.unmarshal_int();
        this.minimal = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SGeneralSummonCommand) {
            SGeneralSummonCommand _o_ = (SGeneralSummonCommand)_o1_;
            if (this.summontype != _o_.summontype) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.mapid != _o_.mapid) {
                return false;
            } else {
                return this.minimal == _o_.minimal;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.summontype;
        _h_ += (int)this.roleid;
        _h_ += (int)this.npckey;
        _h_ += this.mapid;
        _h_ += this.minimal;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.summontype).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.mapid).append(",");
        _sb_.append(this.minimal).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SGeneralSummonCommand _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.summontype - _o_.summontype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.roleid - _o_.roleid);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.npckey - _o_.npckey);
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.mapid - _o_.mapid;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.minimal - _o_.minimal;
                            return 0 != _c_ ? _c_ : _c_;
                        }
                    }
                }
            }
        }
    }
}
