//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SOneTeamRollMelonInfo extends __SOneTeamRollMelonInfo__ {
    public static final int PROTOCOL_TYPE = 794526;
    public long melonid;
    public int itemid;
    public RoleRollInfo rollinfo;

    protected void process() {
    }

    public int getType() {
        return 794526;
    }

    public SOneTeamRollMelonInfo() {
        this.rollinfo = new RoleRollInfo();
    }

    public SOneTeamRollMelonInfo(long _melonid_, int _itemid_, RoleRollInfo _rollinfo_) {
        this.melonid = _melonid_;
        this.itemid = _itemid_;
        this.rollinfo = _rollinfo_;
    }

    public final boolean _validator_() {
        return this.rollinfo._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.melonid);
            _os_.marshal(this.itemid);
            _os_.marshal(this.rollinfo);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.melonid = _os_.unmarshal_long();
        this.itemid = _os_.unmarshal_int();
        this.rollinfo.unmarshal(_os_);
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SOneTeamRollMelonInfo) {
            SOneTeamRollMelonInfo _o_ = (SOneTeamRollMelonInfo)_o1_;
            if (this.melonid != _o_.melonid) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.rollinfo.equals(_o_.rollinfo);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.melonid;
        _h_ += this.itemid;
        _h_ += this.rollinfo.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonid).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.rollinfo).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
