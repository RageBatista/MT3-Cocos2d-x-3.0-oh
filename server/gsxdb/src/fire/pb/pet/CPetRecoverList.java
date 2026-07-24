//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import java.util.LinkedList;
import java.util.List;
import mkdb.Procedure;
import xbean.DiscardPet;
import xbean.Petrecoverlist;
import xtable.Petrecover;
import xtable.Petrecyclebin;

public class CPetRecoverList extends __CPetRecoverList__ {
    public static final int PROTOCOL_TYPE = 788583;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    SPetRecoverList send = new SPetRecoverList();
                    Petrecoverlist petRecoverList = Petrecover.get(roleId);
                    if (petRecoverList != null) {
                        List<Long> removeList = new LinkedList();
                        long now = System.currentTimeMillis();

                        for(Long uniqId : petRecoverList.getUniqids()) {
                            DiscardPet dpet = Petrecyclebin.select(uniqId);
                            if (dpet != null) {
                                long day = 60L;
                                long validTime = day * 24L * 3600L * 1000L;
                                long elapseTime = now - dpet.getDeletedate();
                                long remainTime = validTime - elapseTime;
                                if (remainTime > 0L) {
                                    int cost = -1;
                                    PetAttr petAttrConf = Module.getInstance().getPetManager().getAttr(dpet.getPet().getId());
                                    if (petAttrConf != null) {
                                        cost = petAttrConf.getRecovercost();
                                    }

                                    PetRecoverInfoBean info = new PetRecoverInfoBean();
                                    info.petid = dpet.getPet().getId();
                                    info.uniqid = uniqId;
                                    info.remaintime = (int)(remainTime / 1000L);
                                    info.cost = cost;
                                    send.pets.add(info);
                                }
                            } else {
                                removeList.add(uniqId);
                            }
                        }

                        petRecoverList.getUniqids().removeAll(removeList);
                    }

                    Procedure.psendWhileCommit(roleId, send);
                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 788583;
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
            return _o1_ instanceof CPetRecoverList;
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

    public int compareTo(CPetRecoverList _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
