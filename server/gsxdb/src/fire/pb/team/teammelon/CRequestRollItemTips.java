//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.item.ItemBase;
import fire.pb.item.Module;
import fire.pb.talk.DisplayInfo;
import fire.pb.talk.SChatItemTips;
import gnet.link.Onlines;
import xbean.ETeamMelon;
import xbean.Item;
import xbean.TeamMelon;
import xtable.Battlemelonid2melon;
import xtable.Roleid2battlemelonid;

public class CRequestRollItemTips extends __CRequestRollItemTips__ {
    public static final int PROTOCOL_TYPE = 794525;
    public long melonid;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Long battlemelonid = Roleid2battlemelonid.select(roleid);
            if (battlemelonid != null) {
                ETeamMelon teammelon = Battlemelonid2melon.select(battlemelonid);
                if (teammelon != null) {
                    TeamMelon melon = (TeamMelon)teammelon.getMelonid2melons().get(this.melonid);
                    if (melon != null) {
                        Item item = melon.getItemdata();
                        if (item != null) {
                            ItemBase basicitem = Module.getInstance().getItemManager().toItemBase(item, 0L, 0, 0);
                            if (basicitem != null) {
                                SChatItemTips msg = new SChatItemTips();
                                msg.tips = basicitem.getTips();
                                DisplayInfo displayInfo = new DisplayInfo();
                                msg.displayinfo = displayInfo;
                                msg.displayinfo.displaytype = 11;
                                msg.displayinfo.counterid = item.getId();
                                Onlines.getInstance().send(roleid, msg);
                            }
                        }
                    }
                }
            }

        }
    }

    public int getType() {
        return 794525;
    }

    public CRequestRollItemTips() {
    }

    public CRequestRollItemTips(long _melonid_) {
        this.melonid = _melonid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.melonid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.melonid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestRollItemTips) {
            CRequestRollItemTips _o_ = (CRequestRollItemTips)_o1_;
            return this.melonid == _o_.melonid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.melonid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestRollItemTips _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.melonid - _o_.melonid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
