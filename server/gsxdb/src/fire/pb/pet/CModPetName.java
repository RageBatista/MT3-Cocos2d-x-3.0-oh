//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.talk.MessageMgr;
import fire.pb.util.CheckName;
import gnet.link.Onlines;
import java.util.List;

public class CModPetName extends __CModPetName__ {
    public static final int PROTOCOL_TYPE = 788450;
    public static final int NAMELEN_MAX = 6;
    public static final int NAMELEN_MIN = 1;
    public int petkey;
    public String petname;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (Pet.isInBattle(roleid, this.petkey)) {
                SPetError senderr = new SPetError();
                if (this.petname.length() > 6) {
                    senderr.peterror = -7;
                    Onlines.getInstance().send(roleid, senderr);
                } else if (this.petname.length() < 1) {
                    senderr.peterror = -8;
                    Onlines.getInstance().send(roleid, senderr);
                } else {
                    int resultCode = CheckName.checkValid(this.petname);
                    if (resultCode == -3) {
                        MessageMgr.sendMsgNotify(roleid, 142260, (List)null);
                    } else if (resultCode == -1) {
                        MessageMgr.sendMsgNotify(roleid, 142294, (List)null);
                    } else if (resultCode == -2) {
                        MessageMgr.sendMsgNotify(roleid, 146238, (List)null);
                    } else {
                        PModPetName proc = new PModPetName(roleid, this.petkey, this.petname);
                        proc.submit();
                    }
                }
            }
        }
    }

    public int getType() {
        return 788450;
    }

    public CModPetName() {
        this.petname = "";
    }

    public CModPetName(int _petkey_, String _petname_) {
        this.petkey = _petkey_;
        this.petname = _petname_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.petname, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.petname = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CModPetName) {
            CModPetName _o_ = (CModPetName)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.petname.equals(_o_.petname);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.petname.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append("T").append(this.petname.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
