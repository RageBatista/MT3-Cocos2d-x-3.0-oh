//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SSetPetEquipInfo extends __SSetPetEquipInfo__ {
    public static final int PROTOCOL_TYPE = 817938;
    public int petkey;
    public int itemid;
    public int taozhuangid;
    public HashMap<Integer, Integer> petequipinfo;

    protected void process() {
    }

    public int getType() {
        return 817938;
    }

    public SSetPetEquipInfo() {
        this.petequipinfo = new HashMap();
    }

    public SSetPetEquipInfo(int _petkey_, HashMap<Integer, Integer> _petequipinfo_) {
        this.petkey = _petkey_;
        this.petequipinfo = _petequipinfo_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.itemid);
            _os_.marshal(this.taozhuangid);
            _os_.compact_uint32(this.petequipinfo.size());

            for(Map.Entry<Integer, Integer> _e_ : this.petequipinfo.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.itemid = _os_.unmarshal_int();
        this.taozhuangid = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.petequipinfo.put(_k_, _v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetPetEquipInfo) {
            SSetPetEquipInfo _o_ = (SSetPetEquipInfo)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.taozhuangid != _o_.taozhuangid) {
                return false;
            } else {
                return this.petequipinfo.equals(_o_.petequipinfo);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.itemid;
        _h_ += this.taozhuangid;
        _h_ += this.petequipinfo.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.taozhuangid).append(",");
        _sb_.append(this.petequipinfo).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
