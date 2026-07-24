//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.item.Pack;
import fire.pb.talk.MessageMgr;
import fire.pb.title.Title;
import gnet.link.Onlines;
import java.util.List;
import mkdb.Procedure;

public class COutJieBai extends __COutJieBai__ {
    public static final int PROTOCOL_TYPE = 817953;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure procedure = new Procedure() {
                protected boolean process() {
                    PropRole propRole = new PropRole(roleid, false);
                    Title title = new Title(roleid, false);
                    if (propRole.getjblb().isEmpty()) {
                        MessageMgr.sendMsgNotify(roleid, 191214, (List)null);
                        return false;
                    } else {
                        Pack Pack = new Pack(roleid, false);
                        if (Pack.getBagItemNum(420517) < 1) {
                            MessageMgr.sendMsgNotify(roleid, 191213, (List)null);
                            return false;
                        } else if (Pack.removeItemById(420517, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "退出结拜消耗") != 1) {
                            System.out.println("退出道具消耗失败！");
                            return false;
                        } else {
                            propRole.getjblb().clear();
                            title.removeTitle(213);
                            MessageMgr.sendMsgNotify(roleid, 191215, (List)null);
                            return true;
                        }
                    }
                }
            };
            procedure.submit();
        }
    }

    public int getType() {
        return 817953;
    }

    public COutJieBai() {
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
            return _o1_ instanceof COutJieBai;
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

    public int compareTo(COutJieBai _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
