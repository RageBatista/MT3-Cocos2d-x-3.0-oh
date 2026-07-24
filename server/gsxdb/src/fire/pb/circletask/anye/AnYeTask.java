//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask.anye;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class AnYeTask implements Marshal, Comparable<AnYeTask> {
    public int pos;
    public int id;
    public int kind;
    public int state;
    public int dstitemid;
    public int dstitemnum;
    public long dstnpckey;
    public int dstnpcid;
    public int legend;
    public long legendtime;
    public long legendend;

    public AnYeTask() {
    }

    public AnYeTask(int _pos_, int _id_, int _kind_, int _state_, int _dstitemid_, int _dstitemnum_, long _dstnpckey_, int _dstnpcid_, int _legend_, long _legendtime_, long _legendend_) {
        this.pos = _pos_;
        this.id = _id_;
        this.kind = _kind_;
        this.state = _state_;
        this.dstitemid = _dstitemid_;
        this.dstitemnum = _dstitemnum_;
        this.dstnpckey = _dstnpckey_;
        this.dstnpcid = _dstnpcid_;
        this.legend = _legend_;
        this.legendtime = _legendtime_;
        this.legendend = _legendend_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.pos);
        _os_.marshal(this.id);
        _os_.marshal(this.kind);
        _os_.marshal(this.state);
        _os_.marshal(this.dstitemid);
        _os_.marshal(this.dstitemnum);
        _os_.marshal(this.dstnpckey);
        _os_.marshal(this.dstnpcid);
        _os_.marshal(this.legend);
        _os_.marshal(this.legendtime);
        _os_.marshal(this.legendend);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.pos = _os_.unmarshal_int();
        this.id = _os_.unmarshal_int();
        this.kind = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        this.dstitemid = _os_.unmarshal_int();
        this.dstitemnum = _os_.unmarshal_int();
        this.dstnpckey = _os_.unmarshal_long();
        this.dstnpcid = _os_.unmarshal_int();
        this.legend = _os_.unmarshal_int();
        this.legendtime = _os_.unmarshal_long();
        this.legendend = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof AnYeTask) {
            AnYeTask _o_ = (AnYeTask)_o1_;
            if (this.pos != _o_.pos) {
                return false;
            } else if (this.id != _o_.id) {
                return false;
            } else if (this.kind != _o_.kind) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (this.dstitemid != _o_.dstitemid) {
                return false;
            } else if (this.dstitemnum != _o_.dstitemnum) {
                return false;
            } else if (this.dstnpckey != _o_.dstnpckey) {
                return false;
            } else if (this.dstnpcid != _o_.dstnpcid) {
                return false;
            } else if (this.legend != _o_.legend) {
                return false;
            } else if (this.legendtime != _o_.legendtime) {
                return false;
            } else {
                return this.legendend == _o_.legendend;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.pos;
        _h_ += this.id;
        _h_ += this.kind;
        _h_ += this.state;
        _h_ += this.dstitemid;
        _h_ += this.dstitemnum;
        _h_ += (int)this.dstnpckey;
        _h_ += this.dstnpcid;
        _h_ += this.legend;
        _h_ += (int)this.legendtime;
        _h_ += (int)this.legendend;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.id).append(",");
        _sb_.append(this.kind).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.dstitemid).append(",");
        _sb_.append(this.dstitemnum).append(",");
        _sb_.append(this.dstnpckey).append(",");
        _sb_.append(this.dstnpcid).append(",");
        _sb_.append(this.legend).append(",");
        _sb_.append(this.legendtime).append(",");
        _sb_.append(this.legendend).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(AnYeTask _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.pos - _o_.pos;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.id - _o_.id;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.kind - _o_.kind;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.state - _o_.state;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.dstitemid - _o_.dstitemid;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.dstitemnum - _o_.dstitemnum;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = Long.signum(this.dstnpckey - _o_.dstnpckey);
                                    if (0 != _c_) {
                                        return _c_;
                                    } else {
                                        _c_ = this.dstnpcid - _o_.dstnpcid;
                                        if (0 != _c_) {
                                            return _c_;
                                        } else {
                                            _c_ = this.legend - _o_.legend;
                                            if (0 != _c_) {
                                                return _c_;
                                            } else {
                                                _c_ = Long.signum(this.legendtime - _o_.legendtime);
                                                if (0 != _c_) {
                                                    return _c_;
                                                } else {
                                                    _c_ = Long.signum(this.legendend - _o_.legendend);
                                                    return 0 != _c_ ? _c_ : _c_;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
