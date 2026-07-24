//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package cross;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;
import java.util.Iterator;

public class UserInfo implements Marshal {
    public int userid;
    public int func;
    public int funcparm;
    public int loginip;
    public byte blisgm;
    public ArrayList<Integer> auth;
    public int algorithm;
    public byte gender;
    public Octets nickname;

    public UserInfo() {
        this.auth = new ArrayList();
        this.nickname = new Octets();
    }

    public UserInfo(int _userid_, int _func_, int _funcparm_, int _loginip_, byte _blisgm_, ArrayList<Integer> _auth_, int _algorithm_, byte _gender_, Octets _nickname_) {
        this.userid = _userid_;
        this.func = _func_;
        this.funcparm = _funcparm_;
        this.loginip = _loginip_;
        this.blisgm = _blisgm_;
        this.auth = _auth_;
        this.algorithm = _algorithm_;
        this.gender = _gender_;
        this.nickname = _nickname_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.userid);
        _os_.marshal(this.func);
        _os_.marshal(this.funcparm);
        _os_.marshal(this.loginip);
        _os_.marshal(this.blisgm);
        _os_.compact_uint32(this.auth.size());
        Iterator iterator = this.auth.iterator();

        while(iterator.hasNext()) {
            Integer _v_ = (Integer)iterator.next();
            _os_.marshal(_v_);
        }

        _os_.marshal(this.algorithm);
        _os_.marshal(this.gender);
        _os_.marshal(this.nickname);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.userid = _os_.unmarshal_int();
        this.func = _os_.unmarshal_int();
        this.funcparm = _os_.unmarshal_int();
        this.loginip = _os_.unmarshal_int();
        this.blisgm = _os_.unmarshal_byte();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.auth.add(_v_);
        }

        this.algorithm = _os_.unmarshal_int();
        this.gender = _os_.unmarshal_byte();
        this.nickname = _os_.unmarshal_Octets();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof UserInfo) {
            UserInfo _o_ = (UserInfo)_o1_;
            if (this.userid != _o_.userid) {
                return false;
            } else if (this.func != _o_.func) {
                return false;
            } else if (this.funcparm != _o_.funcparm) {
                return false;
            } else if (this.loginip != _o_.loginip) {
                return false;
            } else if (this.blisgm != _o_.blisgm) {
                return false;
            } else if (!this.auth.equals(_o_.auth)) {
                return false;
            } else if (this.algorithm != _o_.algorithm) {
                return false;
            } else if (this.gender != _o_.gender) {
                return false;
            } else {
                return this.nickname.equals(_o_.nickname);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.userid;
        _h_ += this.func;
        _h_ += this.funcparm;
        _h_ += this.loginip;
        _h_ += this.blisgm;
        _h_ += this.auth.hashCode();
        _h_ += this.algorithm;
        _h_ += this.gender;
        _h_ += this.nickname.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.userid).append(",");
        _sb_.append(this.func).append(",");
        _sb_.append(this.funcparm).append(",");
        _sb_.append(this.loginip).append(",");
        _sb_.append(this.blisgm).append(",");
        _sb_.append(this.auth).append(",");
        _sb_.append(this.algorithm).append(",");
        _sb_.append(this.gender).append(",");
        _sb_.append("B").append(this.nickname.size()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
