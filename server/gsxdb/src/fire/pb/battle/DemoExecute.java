//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class DemoExecute implements Marshal {
    public int attackerid;
    public int hpconsume;
    public int mpconsume;
    public int spconsume;
    public int operationtype;
    public int operationid;
    public int msgid;
    public LinkedList<DemoBuff> demobuffs;

    public DemoExecute() {
        this.demobuffs = new LinkedList();
    }

    public DemoExecute(int _attackerid_, int _hpconsume_, int _mpconsume_, int _spconsume_, int _operationtype_, int _operationid_, int _msgid_, LinkedList<DemoBuff> _demobuffs_) {
        this.attackerid = _attackerid_;
        this.hpconsume = _hpconsume_;
        this.mpconsume = _mpconsume_;
        this.spconsume = _spconsume_;
        this.operationtype = _operationtype_;
        this.operationid = _operationid_;
        this.msgid = _msgid_;
        this.demobuffs = _demobuffs_;
    }

    public final boolean _validator_() {
        for(DemoBuff _v_ : this.demobuffs) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.attackerid);
        _os_.marshal(this.hpconsume);
        _os_.marshal(this.mpconsume);
        _os_.marshal(this.spconsume);
        _os_.marshal(this.operationtype);
        _os_.marshal(this.operationid);
        _os_.marshal(this.msgid);
        _os_.compact_uint32(this.demobuffs.size());

        for(DemoBuff _v_ : this.demobuffs) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.attackerid = _os_.unmarshal_int();
        this.hpconsume = _os_.unmarshal_int();
        this.mpconsume = _os_.unmarshal_int();
        this.spconsume = _os_.unmarshal_int();
        this.operationtype = _os_.unmarshal_int();
        this.operationid = _os_.unmarshal_int();
        this.msgid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            DemoBuff _v_ = new DemoBuff();
            _v_.unmarshal(_os_);
            this.demobuffs.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DemoExecute) {
            DemoExecute _o_ = (DemoExecute)_o1_;
            if (this.attackerid != _o_.attackerid) {
                return false;
            } else if (this.hpconsume != _o_.hpconsume) {
                return false;
            } else if (this.mpconsume != _o_.mpconsume) {
                return false;
            } else if (this.spconsume != _o_.spconsume) {
                return false;
            } else if (this.operationtype != _o_.operationtype) {
                return false;
            } else if (this.operationid != _o_.operationid) {
                return false;
            } else if (this.msgid != _o_.msgid) {
                return false;
            } else {
                return this.demobuffs.equals(_o_.demobuffs);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.attackerid;
        _h_ += this.hpconsume;
        _h_ += this.mpconsume;
        _h_ += this.spconsume;
        _h_ += this.operationtype;
        _h_ += this.operationid;
        _h_ += this.msgid;
        _h_ += this.demobuffs.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.attackerid).append(",");
        _sb_.append(this.hpconsume).append(",");
        _sb_.append(this.mpconsume).append(",");
        _sb_.append(this.spconsume).append(",");
        _sb_.append(this.operationtype).append(",");
        _sb_.append(this.operationid).append(",");
        _sb_.append(this.msgid).append(",");
        _sb_.append(this.demobuffs).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
