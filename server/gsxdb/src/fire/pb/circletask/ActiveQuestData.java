//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class ActiveQuestData implements Marshal {
    public int questid;
    public int queststate;
    public long dstnpckey;
    public int dstnpcid;
    public int dstmapid;
    public int dstx;
    public int dsty;
    public int dstitemid;
    public int sumnum;
    public String npcname;
    public long rewardexp;
    public long rewardmoney;
    public long rewardsmoney;
    public ArrayList<RewardItemUnit> rewarditems;

    public ActiveQuestData() {
        this.npcname = "";
        this.rewarditems = new ArrayList<>();
    }

    public ActiveQuestData(int _questid_, int _queststate_, long _dstnpckey_, int _dstnpcid_, int _dstmapid_, int _dstx_, int _dsty_, int _dstitemid_, int _sumnum_, String _npcname_, long _rewardexp_, long _rewardmoney_, long _rewardsmoney_, ArrayList<RewardItemUnit> _rewarditems_) {
        this.questid = _questid_;
        this.queststate = _queststate_;
        this.dstnpckey = _dstnpckey_;
        this.dstnpcid = _dstnpcid_;
        this.dstmapid = _dstmapid_;
        this.dstx = _dstx_;
        this.dsty = _dsty_;
        this.dstitemid = _dstitemid_;
        this.sumnum = _sumnum_;
        this.npcname = _npcname_;
        this.rewardexp = _rewardexp_;
        this.rewardmoney = _rewardmoney_;
        this.rewardsmoney = _rewardsmoney_;
        this.rewarditems = _rewarditems_;
    }

    public final boolean _validator_() {
        if (this.questid < 1) {
            return false;
        } else {
            for(RewardItemUnit _v_ : this.rewarditems) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.questid);
        _os_.marshal(this.queststate);
        _os_.marshal(this.dstnpckey);
        _os_.marshal(this.dstnpcid);
        _os_.marshal(this.dstmapid);
        _os_.marshal(this.dstx);
        _os_.marshal(this.dsty);
        _os_.marshal(this.dstitemid);
        _os_.marshal(this.sumnum);
        _os_.marshal(this.npcname, "UTF-16LE");
        _os_.marshal(this.rewardexp);
        _os_.marshal(this.rewardmoney);
        _os_.marshal(this.rewardsmoney);
        _os_.compact_uint32(this.rewarditems.size());

        for(RewardItemUnit _v_ : this.rewarditems) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questid = _os_.unmarshal_int();
        this.queststate = _os_.unmarshal_int();
        this.dstnpckey = _os_.unmarshal_long();
        this.dstnpcid = _os_.unmarshal_int();
        this.dstmapid = _os_.unmarshal_int();
        this.dstx = _os_.unmarshal_int();
        this.dsty = _os_.unmarshal_int();
        this.dstitemid = _os_.unmarshal_int();
        this.sumnum = _os_.unmarshal_int();
        this.npcname = _os_.unmarshal_String("UTF-16LE");
        this.rewardexp = _os_.unmarshal_long();
        this.rewardmoney = _os_.unmarshal_long();
        this.rewardsmoney = _os_.unmarshal_long();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            RewardItemUnit _v_ = new RewardItemUnit();
            _v_.unmarshal(_os_);
            this.rewarditems.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ActiveQuestData) {
            ActiveQuestData _o_ = (ActiveQuestData)_o1_;
            if (this.questid != _o_.questid) {
                return false;
            } else if (this.queststate != _o_.queststate) {
                return false;
            } else if (this.dstnpckey != _o_.dstnpckey) {
                return false;
            } else if (this.dstnpcid != _o_.dstnpcid) {
                return false;
            } else if (this.dstmapid != _o_.dstmapid) {
                return false;
            } else if (this.dstx != _o_.dstx) {
                return false;
            } else if (this.dsty != _o_.dsty) {
                return false;
            } else if (this.dstitemid != _o_.dstitemid) {
                return false;
            } else if (this.sumnum != _o_.sumnum) {
                return false;
            } else if (!this.npcname.equals(_o_.npcname)) {
                return false;
            } else if (this.rewardexp != _o_.rewardexp) {
                return false;
            } else if (this.rewardmoney != _o_.rewardmoney) {
                return false;
            } else if (this.rewardsmoney != _o_.rewardsmoney) {
                return false;
            } else {
                return this.rewarditems.equals(_o_.rewarditems);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questid;
        _h_ += this.queststate;
        _h_ += (int)this.dstnpckey;
        _h_ += this.dstnpcid;
        _h_ += this.dstmapid;
        _h_ += this.dstx;
        _h_ += this.dsty;
        _h_ += this.dstitemid;
        _h_ += this.sumnum;
        _h_ += this.npcname.hashCode();
        _h_ += (int)this.rewardexp;
        _h_ += (int)this.rewardmoney;
        _h_ += (int)this.rewardsmoney;
        _h_ += this.rewarditems.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questid).append(",");
        _sb_.append(this.queststate).append(",");
        _sb_.append(this.dstnpckey).append(",");
        _sb_.append(this.dstnpcid).append(",");
        _sb_.append(this.dstmapid).append(",");
        _sb_.append(this.dstx).append(",");
        _sb_.append(this.dsty).append(",");
        _sb_.append(this.dstitemid).append(",");
        _sb_.append(this.sumnum).append(",");
        _sb_.append("T").append(this.npcname.length()).append(",");
        _sb_.append(this.rewardexp).append(",");
        _sb_.append(this.rewardmoney).append(",");
        _sb_.append(this.rewardsmoney).append(",");
        _sb_.append(this.rewarditems).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
