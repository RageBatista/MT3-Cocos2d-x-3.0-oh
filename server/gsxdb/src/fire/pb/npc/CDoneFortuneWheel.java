//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.fanpai.PPlayCardItemProc;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import gnet.link.Onlines;

public class CDoneFortuneWheel extends __CDoneFortuneWheel__ {
    public static final int PROTOCOL_TYPE = 795457;
    public long npckey;
    public int taskid;
    public int succ;
    public byte flag;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (this.flag == 0) {
                PropRole prole = new PropRole(roleid, true);
                Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
                int masterid = ((SchoolMaster)CircleTaskManager.getInstance().getMasterMap().get(prole.getSchool())).masterid;
                if (npc != null && npc.getNpcID() == masterid) {
                }

                (new PFinishFortuneWheel(roleid, this.npckey, this.taskid, this.succ)).submit();
            } else {
                (new PPlayCardItemProc(roleid)).submit();
            }

        }
    }

    public int getType() {
        return 795457;
    }

    public CDoneFortuneWheel() {
    }

    public CDoneFortuneWheel(long _npckey_, int _taskid_, int _succ_, byte _flag_) {
        this.npckey = _npckey_;
        this.taskid = _taskid_;
        this.succ = _succ_;
        this.flag = _flag_;
    }

    public final boolean _validator_() {
        return this.npckey >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.taskid);
            _os_.marshal(this.succ);
            _os_.marshal(this.flag);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.taskid = _os_.unmarshal_int();
        this.succ = _os_.unmarshal_int();
        this.flag = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CDoneFortuneWheel) {
            CDoneFortuneWheel _o_ = (CDoneFortuneWheel)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.taskid != _o_.taskid) {
                return false;
            } else if (this.succ != _o_.succ) {
                return false;
            } else {
                return this.flag == _o_.flag;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.taskid;
        _h_ += this.succ;
        _h_ += this.flag;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.taskid).append(",");
        _sb_.append(this.succ).append(",");
        _sb_.append(this.flag).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CDoneFortuneWheel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.taskid - _o_.taskid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.succ - _o_.succ;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.flag - _o_.flag;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
