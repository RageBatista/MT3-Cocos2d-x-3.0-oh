//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanMember implements Marshal {
    public long roleid;
    public int shapeid;
    public String rolename;
    public short rolelevel;
    public int rolecontribution;
    public int weekcontribution;
    public int historycontribution;
    public int rolefreezedcontribution;
    public int preweekcontribution;
    public int lastonlinetime;
    public byte position;
    public byte school;
    public int jointime;
    public short weekaid;
    public int historyaid;
    public byte isbannedtalk;
    public int fightvalue;
    public short claninstnum;
    public short clanfightnum;

    public ClanMember() {
        this.rolename = "";
    }

    public ClanMember(long _roleid_, int _shapeid_, String _rolename_, short _rolelevel_, int _rolecontribution_, int _weekcontribution_, int _historycontribution_, int _rolefreezedcontribution_, int _preweekcontribution_, int _lastonlinetime_, byte _position_, byte _school_, int _jointime_, short _weekaid_, int _historyaid_, byte _isbannedtalk_, int _fightvalue_, short _claninstnum_, short _clanfightnum_) {
        this.roleid = _roleid_;
        this.shapeid = _shapeid_;
        this.rolename = _rolename_;
        this.rolelevel = _rolelevel_;
        this.rolecontribution = _rolecontribution_;
        this.weekcontribution = _weekcontribution_;
        this.historycontribution = _historycontribution_;
        this.rolefreezedcontribution = _rolefreezedcontribution_;
        this.preweekcontribution = _preweekcontribution_;
        this.lastonlinetime = _lastonlinetime_;
        this.position = _position_;
        this.school = _school_;
        this.jointime = _jointime_;
        this.weekaid = _weekaid_;
        this.historyaid = _historyaid_;
        this.isbannedtalk = _isbannedtalk_;
        this.fightvalue = _fightvalue_;
        this.claninstnum = _claninstnum_;
        this.clanfightnum = _clanfightnum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.shapeid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.rolelevel);
        _os_.marshal(this.rolecontribution);
        _os_.marshal(this.weekcontribution);
        _os_.marshal(this.historycontribution);
        _os_.marshal(this.rolefreezedcontribution);
        _os_.marshal(this.preweekcontribution);
        _os_.marshal(this.lastonlinetime);
        _os_.marshal(this.position);
        _os_.marshal(this.school);
        _os_.marshal(this.jointime);
        _os_.marshal(this.weekaid);
        _os_.marshal(this.historyaid);
        _os_.marshal(this.isbannedtalk);
        _os_.marshal(this.fightvalue);
        _os_.marshal(this.claninstnum);
        _os_.marshal(this.clanfightnum);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.shapeid = _os_.unmarshal_int();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.rolelevel = _os_.unmarshal_short();
        this.rolecontribution = _os_.unmarshal_int();
        this.weekcontribution = _os_.unmarshal_int();
        this.historycontribution = _os_.unmarshal_int();
        this.rolefreezedcontribution = _os_.unmarshal_int();
        this.preweekcontribution = _os_.unmarshal_int();
        this.lastonlinetime = _os_.unmarshal_int();
        this.position = _os_.unmarshal_byte();
        this.school = _os_.unmarshal_byte();
        this.jointime = _os_.unmarshal_int();
        this.weekaid = _os_.unmarshal_short();
        this.historyaid = _os_.unmarshal_int();
        this.isbannedtalk = _os_.unmarshal_byte();
        this.fightvalue = _os_.unmarshal_int();
        this.claninstnum = _os_.unmarshal_short();
        this.clanfightnum = _os_.unmarshal_short();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanMember) {
            ClanMember _o_ = (ClanMember)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.shapeid != _o_.shapeid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.rolelevel != _o_.rolelevel) {
                return false;
            } else if (this.rolecontribution != _o_.rolecontribution) {
                return false;
            } else if (this.weekcontribution != _o_.weekcontribution) {
                return false;
            } else if (this.historycontribution != _o_.historycontribution) {
                return false;
            } else if (this.rolefreezedcontribution != _o_.rolefreezedcontribution) {
                return false;
            } else if (this.preweekcontribution != _o_.preweekcontribution) {
                return false;
            } else if (this.lastonlinetime != _o_.lastonlinetime) {
                return false;
            } else if (this.position != _o_.position) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.jointime != _o_.jointime) {
                return false;
            } else if (this.weekaid != _o_.weekaid) {
                return false;
            } else if (this.historyaid != _o_.historyaid) {
                return false;
            } else if (this.isbannedtalk != _o_.isbannedtalk) {
                return false;
            } else if (this.fightvalue != _o_.fightvalue) {
                return false;
            } else if (this.claninstnum != _o_.claninstnum) {
                return false;
            } else {
                return this.clanfightnum == _o_.clanfightnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.shapeid;
        _h_ += this.rolename.hashCode();
        _h_ += this.rolelevel;
        _h_ += this.rolecontribution;
        _h_ += this.weekcontribution;
        _h_ += this.historycontribution;
        _h_ += this.rolefreezedcontribution;
        _h_ += this.preweekcontribution;
        _h_ += this.lastonlinetime;
        _h_ += this.position;
        _h_ += this.school;
        _h_ += this.jointime;
        _h_ += this.weekaid;
        _h_ += this.historyaid;
        _h_ += this.isbannedtalk;
        _h_ += this.fightvalue;
        _h_ += this.claninstnum;
        _h_ += this.clanfightnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.shapeid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.rolelevel).append(",");
        _sb_.append(this.rolecontribution).append(",");
        _sb_.append(this.weekcontribution).append(",");
        _sb_.append(this.historycontribution).append(",");
        _sb_.append(this.rolefreezedcontribution).append(",");
        _sb_.append(this.preweekcontribution).append(",");
        _sb_.append(this.lastonlinetime).append(",");
        _sb_.append(this.position).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.jointime).append(",");
        _sb_.append(this.weekaid).append(",");
        _sb_.append(this.historyaid).append(",");
        _sb_.append(this.isbannedtalk).append(",");
        _sb_.append(this.fightvalue).append(",");
        _sb_.append(this.claninstnum).append(",");
        _sb_.append(this.clanfightnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
