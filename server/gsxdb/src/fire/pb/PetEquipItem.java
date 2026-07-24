//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class PetEquipItem implements Marshal {
    public int itemid;
    public int pos;
    public int taozhuangid;
    public Map<Integer, Integer> pro;
    public Map<Integer, Integer> skill;

    public PetEquipItem() {
    }

    public PetEquipItem(int _itemid_, int _pos_, int _taozhuangid_, HashMap<Integer, Integer> _pro_, HashMap<Integer, Integer> _skill_) {
        this.itemid = _itemid_;
        this.pos = _pos_;
        this.taozhuangid = _taozhuangid_;
        this.pro = _pro_;
        this.skill = _skill_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemid);
        _os_.marshal(this.pos);
        _os_.marshal(this.taozhuangid);
        _os_.compact_uint32(this.pro.size());

        for(Map.Entry<Integer, Integer> _e_ : this.pro.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.skill.size());

        for(Map.Entry<Integer, Integer> _e_ : this.skill.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemid = _os_.unmarshal_int();
        this.pos = _os_.unmarshal_int();
        this.taozhuangid = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.pro.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.skill.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PetEquipItem) {
            PetEquipItem _o_ = (PetEquipItem)_o1_;
            if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.pos != _o_.pos) {
                return false;
            } else if (this.taozhuangid != _o_.taozhuangid) {
                return false;
            } else if (!this.pro.equals(_o_.pro)) {
                return false;
            } else {
                return this.skill.equals(_o_.skill);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemid;
        _h_ += this.pos;
        _h_ += this.taozhuangid;
        _h_ += this.pro.hashCode();
        _h_ += this.skill.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.taozhuangid).append(",");
        _sb_.append(this.pro).append(",");
        _sb_.append(this.skill).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
