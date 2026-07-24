//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.map.SceneNpcManager;
import gnet.link.Onlines;

public class CGetPetcolumnInfo extends __CGetPetcolumnInfo__ {
    public static final int PROTOCOL_TYPE = 788446;
    public int columnid;
    public long npckey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            switch (this.columnid) {
                case 2:
                    if (!SceneNpcManager.checkDistance(this.npckey, roleid)) {
                        return;
                    }
                case 1:
                case 5:
                    PetColumn petCol = new PetColumn(roleid, this.columnid, true);
                    SGetPetcolumnInfo send = new SGetPetcolumnInfo();
                    send.columnid = this.columnid;
                    send.pets = petCol.getAllProtocolPets();
                    send.colunmsize = petCol.getCapacity();
                    Onlines.getInstance().send(roleid, send);
                case 3:
                case 4:
                default:
            }
        }
    }

    public int getType() {
        return 788446;
    }

    public CGetPetcolumnInfo() {
    }

    public CGetPetcolumnInfo(int _columnid_, long _npckey_) {
        this.columnid = _columnid_;
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        if (this.columnid >= 1 && this.columnid <= 2) {
            return this.npckey >= 1L;
        } else {
            return false;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.columnid);
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.columnid = _os_.unmarshal_int();
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
        } else if (_o1_ instanceof CGetPetcolumnInfo) {
            CGetPetcolumnInfo _o_ = (CGetPetcolumnInfo)_o1_;
            if (this.columnid != _o_.columnid) {
                return false;
            } else {
                return this.npckey == _o_.npckey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.columnid;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.columnid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CGetPetcolumnInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.columnid - _o_.columnid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.npckey - _o_.npckey);
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
