//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.Fighter;
import xtable.Battle;
import xtable.Roleid2battleid;

public class CSetFightPet extends __CSetFightPet__ {
    public static final int PROTOCOL_TYPE = 788440;
    public int petkey;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L && StateCommon.isOnline(roleid)) {
            final Long battleId = Roleid2battleid.select(roleid);
            if (battleId == null) {
                PSetFightPetProc proc = new PSetFightPetProc(roleid, this.petkey, true);
                proc.submit();
            } else {
                Procedure proc = new Procedure() {
                    protected boolean process() throws Exception {
                        BattleInfo battle = Battle.get(battleId);
                        if (battle != null) {
                            Integer index = (Integer)battle.getRoleids().get(roleid);
                            if (index != null) {
                                Fighter fighter = (Fighter)battle.getFighters().get(index);
                                if (fighter != null) {
                                    fighter.setInipetkey(CSetFightPet.this.petkey);
                                    MessageMgr.psendMsgNotifyWhileCommit(roleid, 180031);
                                }
                            }
                        }

                        return true;
                    }
                };
                proc.submit();
            }

        }
    }

    public int getType() {
        return 788440;
    }

    public CSetFightPet() {
    }

    public CSetFightPet(int _petkey_) {
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSetFightPet) {
            CSetFightPet _o_ = (CSetFightPet)_o1_;
            return this.petkey == _o_.petkey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CSetFightPet _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
