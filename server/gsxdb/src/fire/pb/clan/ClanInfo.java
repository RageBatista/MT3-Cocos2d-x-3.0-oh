//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class ClanInfo implements Marshal {
    public String clanname;
    public long clanid;
    public long clankey;
    public int clanlevel;
    public int membersnum;
    public String clanmaster;
    public String clanvicemaster;
    public String clancreator;
    public String clanrank;
    public String clanaim;
    public HashMap<Long, ClanMember> memberlist;
    public HashMap<Integer, ClanSkill> clanskilllist;
    public HashMap<Long, ClanDMapInfo> clandsceneids;

    public ClanInfo() {
        this.clanname = "";
        this.clanmaster = "";
        this.clanvicemaster = "";
        this.clancreator = "";
        this.clanrank = "";
        this.clanaim = "";
        this.memberlist = new HashMap<>();
        this.clanskilllist = new HashMap<>();
        this.clandsceneids = new HashMap<>();
    }

    public ClanInfo(String _clanname_, long _clanid_, long _clankey_, int _clanlevel_, int _membersnum_, String _clanmaster_, String _clanvicemaster_, String _clancreator_, String _clanrank_, String _clanaim_, HashMap<Long, ClanMember> _memberlist_, HashMap<Integer, ClanSkill> _clanskilllist_, HashMap<Long, ClanDMapInfo> _clandsceneids_) {
        this.clanname = _clanname_;
        this.clanid = _clanid_;
        this.clankey = _clankey_;
        this.clanlevel = _clanlevel_;
        this.membersnum = _membersnum_;
        this.clanmaster = _clanmaster_;
        this.clanvicemaster = _clanvicemaster_;
        this.clancreator = _clancreator_;
        this.clanrank = _clanrank_;
        this.clanaim = _clanaim_;
        this.memberlist = _memberlist_;
        this.clanskilllist = _clanskilllist_;
        this.clandsceneids = _clandsceneids_;
    }

    public final boolean _validator_() {
        for(Map.Entry<Long, ClanMember> _e_ : this.memberlist.entrySet()) {
            if (!((ClanMember)_e_.getValue())._validator_()) {
                return false;
            }
        }

        for(Map.Entry<Integer, ClanSkill> _e_ : this.clanskilllist.entrySet()) {
            if (!((ClanSkill)_e_.getValue())._validator_()) {
                return false;
            }
        }

        for(Map.Entry<Long, ClanDMapInfo> _e_ : this.clandsceneids.entrySet()) {
            if (!((ClanDMapInfo)_e_.getValue())._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.clanname, "UTF-16LE");
        _os_.marshal(this.clanid);
        _os_.marshal(this.clankey);
        _os_.marshal(this.clanlevel);
        _os_.marshal(this.membersnum);
        _os_.marshal(this.clanmaster, "UTF-16LE");
        _os_.marshal(this.clanvicemaster, "UTF-16LE");
        _os_.marshal(this.clancreator, "UTF-16LE");
        _os_.marshal(this.clanrank, "UTF-16LE");
        _os_.marshal(this.clanaim, "UTF-16LE");
        _os_.compact_uint32(this.memberlist.size());

        for(Map.Entry<Long, ClanMember> _e_ : this.memberlist.entrySet()) {
            _os_.marshal((Long)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        _os_.compact_uint32(this.clanskilllist.size());

        for(Map.Entry<Integer, ClanSkill> _e_ : this.clanskilllist.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        _os_.compact_uint32(this.clandsceneids.size());

        for(Map.Entry<Long, ClanDMapInfo> _e_ : this.clandsceneids.entrySet()) {
            _os_.marshal((Long)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.clanname = _os_.unmarshal_String("UTF-16LE");
        this.clanid = _os_.unmarshal_long();
        this.clankey = _os_.unmarshal_long();
        this.clanlevel = _os_.unmarshal_int();
        this.membersnum = _os_.unmarshal_int();
        this.clanmaster = _os_.unmarshal_String("UTF-16LE");
        this.clanvicemaster = _os_.unmarshal_String("UTF-16LE");
        this.clancreator = _os_.unmarshal_String("UTF-16LE");
        this.clanrank = _os_.unmarshal_String("UTF-16LE");
        this.clanaim = _os_.unmarshal_String("UTF-16LE");

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            long _k_ = _os_.unmarshal_long();
            ClanMember _v_ = new ClanMember();
            _v_.unmarshal(_os_);
            this.memberlist.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            ClanSkill _v_ = new ClanSkill();
            _v_.unmarshal(_os_);
            this.clanskilllist.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            long _k_ = _os_.unmarshal_long();
            ClanDMapInfo _v_ = new ClanDMapInfo();
            _v_.unmarshal(_os_);
            this.clandsceneids.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanInfo) {
            ClanInfo _o_ = (ClanInfo)_o1_;
            if (!this.clanname.equals(_o_.clanname)) {
                return false;
            } else if (this.clanid != _o_.clanid) {
                return false;
            } else if (this.clankey != _o_.clankey) {
                return false;
            } else if (this.clanlevel != _o_.clanlevel) {
                return false;
            } else if (this.membersnum != _o_.membersnum) {
                return false;
            } else if (!this.clanmaster.equals(_o_.clanmaster)) {
                return false;
            } else if (!this.clanvicemaster.equals(_o_.clanvicemaster)) {
                return false;
            } else if (!this.clancreator.equals(_o_.clancreator)) {
                return false;
            } else if (!this.clanrank.equals(_o_.clanrank)) {
                return false;
            } else if (!this.clanaim.equals(_o_.clanaim)) {
                return false;
            } else if (!this.memberlist.equals(_o_.memberlist)) {
                return false;
            } else if (!this.clanskilllist.equals(_o_.clanskilllist)) {
                return false;
            } else {
                return this.clandsceneids.equals(_o_.clandsceneids);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.clanname.hashCode();
        _h_ += (int)this.clanid;
        _h_ += (int)this.clankey;
        _h_ += this.clanlevel;
        _h_ += this.membersnum;
        _h_ += this.clanmaster.hashCode();
        _h_ += this.clanvicemaster.hashCode();
        _h_ += this.clancreator.hashCode();
        _h_ += this.clanrank.hashCode();
        _h_ += this.clanaim.hashCode();
        _h_ += this.memberlist.hashCode();
        _h_ += this.clanskilllist.hashCode();
        _h_ += this.clandsceneids.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.clanname.length()).append(",");
        _sb_.append(this.clanid).append(",");
        _sb_.append(this.clankey).append(",");
        _sb_.append(this.clanlevel).append(",");
        _sb_.append(this.membersnum).append(",");
        _sb_.append("T").append(this.clanmaster.length()).append(",");
        _sb_.append("T").append(this.clanvicemaster.length()).append(",");
        _sb_.append("T").append(this.clancreator.length()).append(",");
        _sb_.append("T").append(this.clanrank.length()).append(",");
        _sb_.append("T").append(this.clanaim.length()).append(",");
        _sb_.append(this.memberlist).append(",");
        _sb_.append(this.clanskilllist).append(",");
        _sb_.append(this.clandsceneids).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
