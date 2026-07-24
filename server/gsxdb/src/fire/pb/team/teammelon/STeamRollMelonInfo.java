//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class STeamRollMelonInfo extends __STeamRollMelonInfo__ {
    public static final int PROTOCOL_TYPE = 794524;
    public long melonid;
    public LinkedList<RoleRollInfo> rollinfolist;
    public long grabroleid;
    public String grabrolename;
    public LinkedList<MelonItemBagInfo> melonitemlist;

    protected void process() {
    }

    public int getType() {
        return 794524;
    }

    public STeamRollMelonInfo() {
        this.rollinfolist = new LinkedList();
        this.grabrolename = "";
        this.melonitemlist = new LinkedList();
    }

    public STeamRollMelonInfo(long _melonid_, LinkedList<RoleRollInfo> _rollinfolist_, long _grabroleid_, String _grabrolename_, LinkedList<MelonItemBagInfo> _melonitemlist_) {
        this.melonid = _melonid_;
        this.rollinfolist = _rollinfolist_;
        this.grabroleid = _grabroleid_;
        this.grabrolename = _grabrolename_;
        this.melonitemlist = _melonitemlist_;
    }

    public final boolean _validator_() {
        for(RoleRollInfo _v_ : this.rollinfolist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        for(MelonItemBagInfo _v_ : this.melonitemlist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.melonid);
            _os_.compact_uint32(this.rollinfolist.size());

            for(RoleRollInfo _v_ : this.rollinfolist) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.grabroleid);
            _os_.marshal(this.grabrolename, "UTF-16LE");
            _os_.compact_uint32(this.melonitemlist.size());

            for(MelonItemBagInfo _v_ : this.melonitemlist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.melonid = _os_.unmarshal_long();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            RoleRollInfo _v_ = new RoleRollInfo();
            _v_.unmarshal(_os_);
            this.rollinfolist.add(_v_);
        }

        this.grabroleid = _os_.unmarshal_long();
        this.grabrolename = _os_.unmarshal_String("UTF-16LE");

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            MelonItemBagInfo _v_ = new MelonItemBagInfo();
            _v_.unmarshal(_os_);
            this.melonitemlist.add(_v_);
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
        } else if (_o1_ instanceof STeamRollMelonInfo) {
            STeamRollMelonInfo _o_ = (STeamRollMelonInfo)_o1_;
            if (this.melonid != _o_.melonid) {
                return false;
            } else if (!this.rollinfolist.equals(_o_.rollinfolist)) {
                return false;
            } else if (this.grabroleid != _o_.grabroleid) {
                return false;
            } else if (!this.grabrolename.equals(_o_.grabrolename)) {
                return false;
            } else {
                return this.melonitemlist.equals(_o_.melonitemlist);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.melonid;
        _h_ += this.rollinfolist.hashCode();
        _h_ += (int)this.grabroleid;
        _h_ += this.grabrolename.hashCode();
        _h_ += this.melonitemlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonid).append(",");
        _sb_.append(this.rollinfolist).append(",");
        _sb_.append(this.grabroleid).append(",");
        _sb_.append("T").append(this.grabrolename.length()).append(",");
        _sb_.append(this.melonitemlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
