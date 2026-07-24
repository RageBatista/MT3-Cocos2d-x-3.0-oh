//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.npcBattleInfoCol;
import xtable.Npcbattleinfo;
import xtable.Role2npcbattle;

public class CAbandonMacth extends __CAbandonMacth__ {
    public static final int PROTOCOL_TYPE = 795670;
    public long npckey;

    protected void process() {
        final Long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    npcBattleInfoCol npcBattle = Npcbattleinfo.get(CAbandonMacth.this.npckey);
                    if (npcBattle == null) {
                        return false;
                    } else if (!npcBattle.getBattleroles().containsKey(roleid)) {
                        return false;
                    } else {
                        npcBattle.getBattleroles().remove(roleid);
                        Role2npcbattle.remove(roleid);
                        List<Long> allRoles = new ArrayList();
                        Team team = TeamManager.selectTeamByRoleId(roleid);
                        if (team != null) {
                            allRoles.addAll(team.getNormalMemberIds());
                            Procedure.psend(allRoles, new SMacthResult(CAbandonMacth.this.npckey, 0));
                        }

                        if (npcBattle.getBattleroles().size() == 0) {
                            Npcbattleinfo.remove(CAbandonMacth.this.npckey);
                        }

                        return true;
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 795670;
    }

    public CAbandonMacth() {
    }

    public CAbandonMacth(long _npckey_) {
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAbandonMacth) {
            CAbandonMacth _o_ = (CAbandonMacth)_o1_;
            return this.npckey == _o_.npckey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAbandonMacth _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
