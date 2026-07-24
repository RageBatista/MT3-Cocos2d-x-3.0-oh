//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ImpExamBean implements Marshal, Comparable<ImpExamBean> {
    public int questionid;
    public int questionnum;
    public int righttimes;
    public long remaintime;
    public byte lastright;
    public int accuexp;
    public int accumoney;
    public int delwrongval;
    public int chorightval;
    public int helpcnt;

    public ImpExamBean() {
    }

    public ImpExamBean(int _questionid_, int _questionnum_, int _righttimes_, long _remaintime_, byte _lastright_, int _accuexp_, int _accumoney_, int _delwrongval_, int _chorightval_, int _helpcnt_) {
        this.questionid = _questionid_;
        this.questionnum = _questionnum_;
        this.righttimes = _righttimes_;
        this.remaintime = _remaintime_;
        this.lastright = _lastright_;
        this.accuexp = _accuexp_;
        this.accumoney = _accumoney_;
        this.delwrongval = _delwrongval_;
        this.chorightval = _chorightval_;
        this.helpcnt = _helpcnt_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.questionid);
        _os_.marshal(this.questionnum);
        _os_.marshal(this.righttimes);
        _os_.marshal(this.remaintime);
        _os_.marshal(this.lastright);
        _os_.marshal(this.accuexp);
        _os_.marshal(this.accumoney);
        _os_.marshal(this.delwrongval);
        _os_.marshal(this.chorightval);
        _os_.marshal(this.helpcnt);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questionid = _os_.unmarshal_int();
        this.questionnum = _os_.unmarshal_int();
        this.righttimes = _os_.unmarshal_int();
        this.remaintime = _os_.unmarshal_long();
        this.lastright = _os_.unmarshal_byte();
        this.accuexp = _os_.unmarshal_int();
        this.accumoney = _os_.unmarshal_int();
        this.delwrongval = _os_.unmarshal_int();
        this.chorightval = _os_.unmarshal_int();
        this.helpcnt = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ImpExamBean) {
            ImpExamBean _o_ = (ImpExamBean)_o1_;
            if (this.questionid != _o_.questionid) {
                return false;
            } else if (this.questionnum != _o_.questionnum) {
                return false;
            } else if (this.righttimes != _o_.righttimes) {
                return false;
            } else if (this.remaintime != _o_.remaintime) {
                return false;
            } else if (this.lastright != _o_.lastright) {
                return false;
            } else if (this.accuexp != _o_.accuexp) {
                return false;
            } else if (this.accumoney != _o_.accumoney) {
                return false;
            } else if (this.delwrongval != _o_.delwrongval) {
                return false;
            } else if (this.chorightval != _o_.chorightval) {
                return false;
            } else {
                return this.helpcnt == _o_.helpcnt;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questionid;
        _h_ += this.questionnum;
        _h_ += this.righttimes;
        _h_ += (int)this.remaintime;
        _h_ += this.lastright;
        _h_ += this.accuexp;
        _h_ += this.accumoney;
        _h_ += this.delwrongval;
        _h_ += this.chorightval;
        _h_ += this.helpcnt;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questionid).append(",");
        _sb_.append(this.questionnum).append(",");
        _sb_.append(this.righttimes).append(",");
        _sb_.append(this.remaintime).append(",");
        _sb_.append(this.lastright).append(",");
        _sb_.append(this.accuexp).append(",");
        _sb_.append(this.accumoney).append(",");
        _sb_.append(this.delwrongval).append(",");
        _sb_.append(this.chorightval).append(",");
        _sb_.append(this.helpcnt).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ImpExamBean _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.questionid - _o_.questionid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.questionnum - _o_.questionnum;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.righttimes - _o_.righttimes;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = Long.signum(this.remaintime - _o_.remaintime);
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.lastright - _o_.lastright;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.accuexp - _o_.accuexp;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = this.accumoney - _o_.accumoney;
                                    if (0 != _c_) {
                                        return _c_;
                                    } else {
                                        _c_ = this.delwrongval - _o_.delwrongval;
                                        if (0 != _c_) {
                                            return _c_;
                                        } else {
                                            _c_ = this.chorightval - _o_.chorightval;
                                            if (0 != _c_) {
                                                return _c_;
                                            } else {
                                                _c_ = this.helpcnt - _o_.helpcnt;
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
