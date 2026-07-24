//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;

public class DynamicSceneParams implements Marshal {
    public int mazeid;
    public LinkedList<CreateNpcInfo> addnpcs;
    public LinkedList<Integer> delnpcs;
    public HashMap<Integer, Integer> npcstates;

    public DynamicSceneParams() {
        this.addnpcs = new LinkedList();
        this.delnpcs = new LinkedList();
        this.npcstates = new HashMap();
    }

    public DynamicSceneParams(int _mazeid_, LinkedList<CreateNpcInfo> _addnpcs_, LinkedList<Integer> _delnpcs_, HashMap<Integer, Integer> _npcstates_) {
        this.mazeid = _mazeid_;
        this.addnpcs = _addnpcs_;
        this.delnpcs = _delnpcs_;
        this.npcstates = _npcstates_;
    }

    public final boolean _validator_() {
        Iterator var1 = this.addnpcs.iterator();

        CreateNpcInfo _v_;
        do {
            if (!var1.hasNext()) {
                return true;
            }

            _v_ = (CreateNpcInfo)var1.next();
        } while(_v_._validator_());

        return false;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.mazeid);
        _os_.compact_uint32(this.addnpcs.size());
        Iterator var2 = this.addnpcs.iterator();

        while(var2.hasNext()) {
            CreateNpcInfo _v_ = (CreateNpcInfo)var2.next();
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.delnpcs.size());
        var2 = this.delnpcs.iterator();

        while(var2.hasNext()) {
            Integer _v_ = (Integer)var2.next();
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.npcstates.size());
        var2 = this.npcstates.entrySet().iterator();

        while(var2.hasNext()) {
            Map.Entry<Integer, Integer> _e_ = (Map.Entry)var2.next();
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.mazeid = _os_.unmarshal_int();

        int size;
        for(size = _os_.uncompact_uint32(); size > 0; --size) {
            CreateNpcInfo _v_ = new CreateNpcInfo();
            _v_.unmarshal(_os_);
            this.addnpcs.add(_v_);
        }

        int _k_;
        for(size = _os_.uncompact_uint32(); size > 0; --size) {
            _k_ = _os_.unmarshal_int();
            this.delnpcs.add(_k_);
        }

        for(size = _os_.uncompact_uint32(); size > 0; --size) {
            _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.npcstates.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DynamicSceneParams) {
            DynamicSceneParams _o_ = (DynamicSceneParams)_o1_;
            if (this.mazeid != _o_.mazeid) {
                return false;
            } else if (!this.addnpcs.equals(_o_.addnpcs)) {
                return false;
            } else if (!this.delnpcs.equals(_o_.delnpcs)) {
                return false;
            } else {
                return this.npcstates.equals(_o_.npcstates);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.mazeid;
        _h_ += this.addnpcs.hashCode();
        _h_ += this.delnpcs.hashCode();
        _h_ += this.npcstates.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.mazeid).append(",");
        _sb_.append(this.addnpcs).append(",");
        _sb_.append(this.delnpcs).append(",");
        _sb_.append(this.npcstates).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
