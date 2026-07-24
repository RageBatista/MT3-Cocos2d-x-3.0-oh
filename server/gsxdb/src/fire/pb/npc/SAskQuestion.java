//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SAskQuestion extends __SAskQuestion__ {
    public static final int PROTOCOL_TYPE = 795520;
    public static final int QUEST = 1;
    public static final int INSTANCE_ZONE = 2;
    public static final int FRIEND_NPC_CHAT = 3;
    public static final int SPECIALQUEST_ANSWER = 5;
    public static final int GUILD_ANSWER = 7;
    public static final int ACTIVITY_ANSWER = 8;
    public byte lastresult;
    public int questionid;
    public int questiontype;
    public long npckey;
    public int xiangguanid;
    public int lasttime;
    public int cur;
    public int num;
    public int totalexp;
    public int totalmoney;
    public int helptimes;
    public int grab;
    public LinkedList<Integer> rightanswer;

    protected void process() {
    }

    public int getType() {
        return 795520;
    }

    public SAskQuestion() {
        this.rightanswer = new LinkedList();
    }

    public SAskQuestion(byte _lastresult_, int _questionid_, int _questiontype_, long _npckey_, int _xiangguanid_, int _lasttime_, int _cur_, int _num_, int _totalexp_, int _totalmoney_, int _helptimes_, int _grab_, LinkedList<Integer> _rightanswer_) {
        this.lastresult = _lastresult_;
        this.questionid = _questionid_;
        this.questiontype = _questiontype_;
        this.npckey = _npckey_;
        this.xiangguanid = _xiangguanid_;
        this.lasttime = _lasttime_;
        this.cur = _cur_;
        this.num = _num_;
        this.totalexp = _totalexp_;
        this.totalmoney = _totalmoney_;
        this.helptimes = _helptimes_;
        this.grab = _grab_;
        this.rightanswer = _rightanswer_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.lastresult);
            _os_.marshal(this.questionid);
            _os_.marshal(this.questiontype);
            _os_.marshal(this.npckey);
            _os_.marshal(this.xiangguanid);
            _os_.marshal(this.lasttime);
            _os_.marshal(this.cur);
            _os_.marshal(this.num);
            _os_.marshal(this.totalexp);
            _os_.marshal(this.totalmoney);
            _os_.marshal(this.helptimes);
            _os_.marshal(this.grab);
            _os_.compact_uint32(this.rightanswer.size());

            for(Integer _v_ : this.rightanswer) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.lastresult = _os_.unmarshal_byte();
        this.questionid = _os_.unmarshal_int();
        this.questiontype = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.xiangguanid = _os_.unmarshal_int();
        this.lasttime = _os_.unmarshal_int();
        this.cur = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.totalexp = _os_.unmarshal_int();
        this.totalmoney = _os_.unmarshal_int();
        this.helptimes = _os_.unmarshal_int();
        this.grab = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.rightanswer.add(_v_);
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
        } else if (_o1_ instanceof SAskQuestion) {
            SAskQuestion _o_ = (SAskQuestion)_o1_;
            if (this.lastresult != _o_.lastresult) {
                return false;
            } else if (this.questionid != _o_.questionid) {
                return false;
            } else if (this.questiontype != _o_.questiontype) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.xiangguanid != _o_.xiangguanid) {
                return false;
            } else if (this.lasttime != _o_.lasttime) {
                return false;
            } else if (this.cur != _o_.cur) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else if (this.totalexp != _o_.totalexp) {
                return false;
            } else if (this.totalmoney != _o_.totalmoney) {
                return false;
            } else if (this.helptimes != _o_.helptimes) {
                return false;
            } else if (this.grab != _o_.grab) {
                return false;
            } else {
                return this.rightanswer.equals(_o_.rightanswer);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.lastresult;
        _h_ += this.questionid;
        _h_ += this.questiontype;
        _h_ += (int)this.npckey;
        _h_ += this.xiangguanid;
        _h_ += this.lasttime;
        _h_ += this.cur;
        _h_ += this.num;
        _h_ += this.totalexp;
        _h_ += this.totalmoney;
        _h_ += this.helptimes;
        _h_ += this.grab;
        _h_ += this.rightanswer.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.lastresult).append(",");
        _sb_.append(this.questionid).append(",");
        _sb_.append(this.questiontype).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.xiangguanid).append(",");
        _sb_.append(this.lasttime).append(",");
        _sb_.append(this.cur).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.totalexp).append(",");
        _sb_.append(this.totalmoney).append(",");
        _sb_.append(this.helptimes).append(",");
        _sb_.append(this.grab).append(",");
        _sb_.append(this.rightanswer).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
