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

public class CSetFightPetRest extends __CSetFightPetRest__ {
    public static final int PROTOCOL_TYPE = 788442;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L && StateCommon.isOnline(roleid)) {
            final Long battleId = Roleid2battleid.select(roleid);
            if (battleId == null) {
                PSetFightPetProc proc = new PSetFightPetProc(roleid, 0, false);
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
                                    fighter.setInipetkey(-1);
                                    MessageMgr.psendMsgNotifyWhileCommit(roleid, 150090);
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
        return 788442;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof CSetFightPetRest;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CSetFightPetRest _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
