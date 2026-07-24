//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class NewDemoResult implements Marshal {
    public static final int HP_CHANGE = 1;
    public static final int MP_CHANGE = 2;
    public static final int SP_CHANGE = 3;
    public static final int UL_HP_CHANGE = 4;
    public static final int TARGET_RESULT = 5;
    public static final int RETURN_HURT = 6;
    public static final int ATTACK_BACK = 7;
    public static final int STEAL_HP = 8;
    public static final int ATTACKER_RESULT = 9;
    public static final int PROTECTER_ID = 10;
    public static final int PROTECTER_HP_CHANGE = 11;
    public static final int PROTECTER_RESULT = 12;
    public static final int ASSISTER_ID = 13;
    public static final int STEAL_MP = 14;
    public static final int RETURN_HURT_DEATH = 15;
    public static final int PROTECTER_MAXHP_CHANGE = 16;
    public static final int MESSAGE_ID = 17;
    public static final int HP_GODBLESS = 18;
    public static final int EP_CHANGE = 19;
    public static final int SHAPE_CHANGE = 20;
    public int resulttype;
    public int targetid;
    public int flagtype;
    public LinkedList<DemoBuff> demobuffs;
    public LinkedList<DemoAttr> demoattrs;
    public HashMap<Integer, Integer> datas;

    public NewDemoResult() {
        this.demobuffs = new LinkedList<>();
        this.demoattrs = new LinkedList<>();
        this.datas = new HashMap<>();
    }

    public NewDemoResult(int _resulttype_, int _targetid_, int _flagtype_, LinkedList<DemoBuff> _demobuffs_, LinkedList<DemoAttr> _demoattrs_, HashMap<Integer, Integer> _datas_) {
        this.resulttype = _resulttype_;
        this.targetid = _targetid_;
        this.flagtype = _flagtype_;
        this.demobuffs = _demobuffs_;
        this.demoattrs = _demoattrs_;
        this.datas = _datas_;
    }

    public final boolean _validator_() {
        for(DemoBuff _v_ : this.demobuffs) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        for(DemoAttr _v_ : this.demoattrs) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.resulttype);
        _os_.marshal(this.targetid);
        _os_.marshal(this.flagtype);
        _os_.compact_uint32(this.demobuffs.size());

        for(DemoBuff _v_ : this.demobuffs) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.demoattrs.size());

        for(DemoAttr _v_ : this.demoattrs) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.datas.size());

        for(Map.Entry<Integer, Integer> _e_ : this.datas.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.resulttype = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();
        this.flagtype = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            DemoBuff _v_ = new DemoBuff();
            _v_.unmarshal(_os_);
            this.demobuffs.add(_v_);
        }

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            DemoAttr _v_ = new DemoAttr();
            _v_.unmarshal(_os_);
            this.demoattrs.add(_v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.datas.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof NewDemoResult) {
            NewDemoResult _o_ = (NewDemoResult)_o1_;
            if (this.resulttype != _o_.resulttype) {
                return false;
            } else if (this.targetid != _o_.targetid) {
                return false;
            } else if (this.flagtype != _o_.flagtype) {
                return false;
            } else if (!this.demobuffs.equals(_o_.demobuffs)) {
                return false;
            } else if (!this.demoattrs.equals(_o_.demoattrs)) {
                return false;
            } else {
                return this.datas.equals(_o_.datas);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.resulttype;
        _h_ += this.targetid;
        _h_ += this.flagtype;
        _h_ += this.demobuffs.hashCode();
        _h_ += this.demoattrs.hashCode();
        _h_ += this.datas.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.resulttype).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.flagtype).append(",");
        _sb_.append(this.demobuffs).append(",");
        _sb_.append(this.demoattrs).append(",");
        _sb_.append(this.datas).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
