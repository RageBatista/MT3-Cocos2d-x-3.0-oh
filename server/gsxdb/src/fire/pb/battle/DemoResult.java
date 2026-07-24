//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class DemoResult implements Marshal {
    public int resulttype;
    public int targetid;
    public int flagtype;
    public int hpchange;
    public int mpchange;
    public int spchange;
    public int epchange;
    public int shapechange;
    public int uplimithpchange;
    public int targetresult;
    public int returnhurt;
    public int attackback;
    public int stealhp;
    public int attackerresult;
    public int attackerulhpchange;
    public int protecterid;
    public int protecterhpchange;
    public int protecterulhpchange;
    public int protecterresult;
    public int assisterid;
    public int stealmp;
    public int godblesshp;
    public LinkedList<DemoBuff> demobuffs;
    public LinkedList<DemoAttr> demoattrs;

    public DemoResult() {
        this.demobuffs = new LinkedList<>();
        this.demoattrs = new LinkedList<>();
    }

    public DemoResult(int _resulttype_, int _targetid_, int _flagtype_, int _hpchange_, int _mpchange_, int _spchange_, int _epchange_, int _shapechange_, int _uplimithpchange_, int _targetresult_, int _returnhurt_, int _attackback_, int _stealhp_, int _attackerresult_, int _attackerulhpchange_, int _protecterid_, int _protecterhpchange_, int _protecterulhpchange_, int _protecterresult_, int _assisterid_, int _stealmp_, int _godblesshp_, LinkedList<DemoBuff> _demobuffs_, LinkedList<DemoAttr> _demoattrs_) {
        this.resulttype = _resulttype_;
        this.targetid = _targetid_;
        this.flagtype = _flagtype_;
        this.hpchange = _hpchange_;
        this.mpchange = _mpchange_;
        this.spchange = _spchange_;
        this.epchange = _epchange_;
        this.shapechange = _shapechange_;
        this.uplimithpchange = _uplimithpchange_;
        this.targetresult = _targetresult_;
        this.returnhurt = _returnhurt_;
        this.attackback = _attackback_;
        this.stealhp = _stealhp_;
        this.attackerresult = _attackerresult_;
        this.attackerulhpchange = _attackerulhpchange_;
        this.protecterid = _protecterid_;
        this.protecterhpchange = _protecterhpchange_;
        this.protecterulhpchange = _protecterulhpchange_;
        this.protecterresult = _protecterresult_;
        this.assisterid = _assisterid_;
        this.stealmp = _stealmp_;
        this.godblesshp = _godblesshp_;
        this.demobuffs = _demobuffs_;
        this.demoattrs = _demoattrs_;
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
        _os_.marshal(this.hpchange);
        _os_.marshal(this.mpchange);
        _os_.marshal(this.spchange);
        _os_.marshal(this.epchange);
        _os_.marshal(this.shapechange);
        _os_.marshal(this.uplimithpchange);
        _os_.marshal(this.targetresult);
        _os_.marshal(this.returnhurt);
        _os_.marshal(this.attackback);
        _os_.marshal(this.stealhp);
        _os_.marshal(this.attackerresult);
        _os_.marshal(this.attackerulhpchange);
        _os_.marshal(this.protecterid);
        _os_.marshal(this.protecterhpchange);
        _os_.marshal(this.protecterulhpchange);
        _os_.marshal(this.protecterresult);
        _os_.marshal(this.assisterid);
        _os_.marshal(this.stealmp);
        _os_.marshal(this.godblesshp);
        _os_.compact_uint32(this.demobuffs.size());

        for(DemoBuff _v_ : this.demobuffs) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.demoattrs.size());

        for(DemoAttr _v_ : this.demoattrs) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.resulttype = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();
        this.flagtype = _os_.unmarshal_int();
        this.hpchange = _os_.unmarshal_int();
        this.mpchange = _os_.unmarshal_int();
        this.spchange = _os_.unmarshal_int();
        this.epchange = _os_.unmarshal_int();
        this.shapechange = _os_.unmarshal_int();
        this.uplimithpchange = _os_.unmarshal_int();
        this.targetresult = _os_.unmarshal_int();
        this.returnhurt = _os_.unmarshal_int();
        this.attackback = _os_.unmarshal_int();
        this.stealhp = _os_.unmarshal_int();
        this.attackerresult = _os_.unmarshal_int();
        this.attackerulhpchange = _os_.unmarshal_int();
        this.protecterid = _os_.unmarshal_int();
        this.protecterhpchange = _os_.unmarshal_int();
        this.protecterulhpchange = _os_.unmarshal_int();
        this.protecterresult = _os_.unmarshal_int();
        this.assisterid = _os_.unmarshal_int();
        this.stealmp = _os_.unmarshal_int();
        this.godblesshp = _os_.unmarshal_int();

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

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DemoResult) {
            DemoResult _o_ = (DemoResult)_o1_;
            if (this.resulttype != _o_.resulttype) {
                return false;
            } else if (this.targetid != _o_.targetid) {
                return false;
            } else if (this.flagtype != _o_.flagtype) {
                return false;
            } else if (this.hpchange != _o_.hpchange) {
                return false;
            } else if (this.mpchange != _o_.mpchange) {
                return false;
            } else if (this.spchange != _o_.spchange) {
                return false;
            } else if (this.epchange != _o_.epchange) {
                return false;
            } else if (this.shapechange != _o_.shapechange) {
                return false;
            } else if (this.uplimithpchange != _o_.uplimithpchange) {
                return false;
            } else if (this.targetresult != _o_.targetresult) {
                return false;
            } else if (this.returnhurt != _o_.returnhurt) {
                return false;
            } else if (this.attackback != _o_.attackback) {
                return false;
            } else if (this.stealhp != _o_.stealhp) {
                return false;
            } else if (this.attackerresult != _o_.attackerresult) {
                return false;
            } else if (this.attackerulhpchange != _o_.attackerulhpchange) {
                return false;
            } else if (this.protecterid != _o_.protecterid) {
                return false;
            } else if (this.protecterhpchange != _o_.protecterhpchange) {
                return false;
            } else if (this.protecterulhpchange != _o_.protecterulhpchange) {
                return false;
            } else if (this.protecterresult != _o_.protecterresult) {
                return false;
            } else if (this.assisterid != _o_.assisterid) {
                return false;
            } else if (this.stealmp != _o_.stealmp) {
                return false;
            } else if (this.godblesshp != _o_.godblesshp) {
                return false;
            } else if (!this.demobuffs.equals(_o_.demobuffs)) {
                return false;
            } else {
                return this.demoattrs.equals(_o_.demoattrs);
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
        _h_ += this.hpchange;
        _h_ += this.mpchange;
        _h_ += this.spchange;
        _h_ += this.epchange;
        _h_ += this.shapechange;
        _h_ += this.uplimithpchange;
        _h_ += this.targetresult;
        _h_ += this.returnhurt;
        _h_ += this.attackback;
        _h_ += this.stealhp;
        _h_ += this.attackerresult;
        _h_ += this.attackerulhpchange;
        _h_ += this.protecterid;
        _h_ += this.protecterhpchange;
        _h_ += this.protecterulhpchange;
        _h_ += this.protecterresult;
        _h_ += this.assisterid;
        _h_ += this.stealmp;
        _h_ += this.godblesshp;
        _h_ += this.demobuffs.hashCode();
        _h_ += this.demoattrs.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.resulttype).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.flagtype).append(",");
        _sb_.append(this.hpchange).append(",");
        _sb_.append(this.mpchange).append(",");
        _sb_.append(this.spchange).append(",");
        _sb_.append(this.epchange).append(",");
        _sb_.append(this.shapechange).append(",");
        _sb_.append(this.uplimithpchange).append(",");
        _sb_.append(this.targetresult).append(",");
        _sb_.append(this.returnhurt).append(",");
        _sb_.append(this.attackback).append(",");
        _sb_.append(this.stealhp).append(",");
        _sb_.append(this.attackerresult).append(",");
        _sb_.append(this.attackerulhpchange).append(",");
        _sb_.append(this.protecterid).append(",");
        _sb_.append(this.protecterhpchange).append(",");
        _sb_.append(this.protecterulhpchange).append(",");
        _sb_.append(this.protecterresult).append(",");
        _sb_.append(this.assisterid).append(",");
        _sb_.append(this.stealmp).append(",");
        _sb_.append(this.godblesshp).append(",");
        _sb_.append(this.demobuffs).append(",");
        _sb_.append(this.demoattrs).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
