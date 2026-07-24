//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import gnet.link.Onlines;

public class CFinishFortuneWheel extends __CFinishFortuneWheel__ {
    public static final int PROTOCOL_TYPE = 795446;
    public long npckey;
    public int serviceid;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PropRole prole = new PropRole(roleid, true);
            Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
            int masterid = ((SchoolMaster)CircleTaskManager.getInstance().getMasterMap().get(prole.getSchool())).masterid;
            if (npc != null && npc.getNpcID() == masterid) {
            }

            (new PFinishFortuneWheel(roleid, this.npckey, this.serviceid, 1)).submit();
        }
    }

    public int getType() {
        return 795446;
    }

    public CFinishFortuneWheel() {
    }

    public CFinishFortuneWheel(long _npckey_, int _serviceid_) {
        this.npckey = _npckey_;
        this.serviceid = _serviceid_;
    }

    public final boolean _validator_() {
        return this.npckey >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.serviceid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.serviceid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CFinishFortuneWheel) {
            CFinishFortuneWheel _o_ = (CFinishFortuneWheel)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else {
                return this.serviceid == _o_.serviceid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.serviceid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.serviceid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CFinishFortuneWheel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.serviceid - _o_.serviceid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
