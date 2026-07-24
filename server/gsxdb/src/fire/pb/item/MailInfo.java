//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class MailInfo implements Marshal {
    public byte kind;
    public long id;
    public byte readflag;
    public String time;
    public String title;
    public int contentid;
    public String content;
    public int awardid;
    public HashMap<Integer, Integer> items;
    public long awardexp;
    public long awardfushi;
    public long awardgold;
    public long awardmoney;
    public long awardvipexp;
    public int npcid;

    public MailInfo() {
        this.time = "";
        this.title = "";
        this.content = "";
        this.items = new HashMap();
    }

    public MailInfo(byte _kind_, long _id_, byte _readflag_, String _time_, String _title_, int _contentid_, String _content_, int _awardid_, HashMap<Integer, Integer> _items_, long _awardexp_, long _awardfushi_, long _awardgold_, long _awardmoney_, long _awardvipexp_, int _npcid_) {
        this.kind = _kind_;
        this.id = _id_;
        this.readflag = _readflag_;
        this.time = _time_;
        this.title = _title_;
        this.contentid = _contentid_;
        this.content = _content_;
        this.awardid = _awardid_;
        this.items = _items_;
        this.awardexp = _awardexp_;
        this.awardfushi = _awardfushi_;
        this.awardgold = _awardgold_;
        this.awardmoney = _awardmoney_;
        this.awardvipexp = _awardvipexp_;
        this.npcid = _npcid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.kind);
        _os_.marshal(this.id);
        _os_.marshal(this.readflag);
        _os_.marshal(this.time, "UTF-16LE");
        _os_.marshal(this.title, "UTF-16LE");
        _os_.marshal(this.contentid);
        _os_.marshal(this.content, "UTF-16LE");
        _os_.marshal(this.awardid);
        _os_.compact_uint32(this.items.size());

        for(Map.Entry<Integer, Integer> _e_ : this.items.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal(this.awardexp);
        _os_.marshal(this.awardfushi);
        _os_.marshal(this.awardgold);
        _os_.marshal(this.awardmoney);
        _os_.marshal(this.awardvipexp);
        _os_.marshal(this.npcid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.kind = _os_.unmarshal_byte();
        this.id = _os_.unmarshal_long();
        this.readflag = _os_.unmarshal_byte();
        this.time = _os_.unmarshal_String("UTF-16LE");
        this.title = _os_.unmarshal_String("UTF-16LE");
        this.contentid = _os_.unmarshal_int();
        this.content = _os_.unmarshal_String("UTF-16LE");
        this.awardid = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.items.put(_k_, _v_);
        }

        this.awardexp = _os_.unmarshal_long();
        this.awardfushi = _os_.unmarshal_long();
        this.awardgold = _os_.unmarshal_long();
        this.awardmoney = _os_.unmarshal_long();
        this.awardvipexp = _os_.unmarshal_long();
        this.npcid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MailInfo) {
            MailInfo _o_ = (MailInfo)_o1_;
            if (this.kind != _o_.kind) {
                return false;
            } else if (this.id != _o_.id) {
                return false;
            } else if (this.readflag != _o_.readflag) {
                return false;
            } else if (!this.time.equals(_o_.time)) {
                return false;
            } else if (!this.title.equals(_o_.title)) {
                return false;
            } else if (this.contentid != _o_.contentid) {
                return false;
            } else if (!this.content.equals(_o_.content)) {
                return false;
            } else if (this.awardid != _o_.awardid) {
                return false;
            } else if (!this.items.equals(_o_.items)) {
                return false;
            } else if (this.awardexp != _o_.awardexp) {
                return false;
            } else if (this.awardfushi != _o_.awardfushi) {
                return false;
            } else if (this.awardgold != _o_.awardgold) {
                return false;
            } else if (this.awardmoney != _o_.awardmoney) {
                return false;
            } else if (this.awardvipexp != _o_.awardvipexp) {
                return false;
            } else {
                return this.npcid == _o_.npcid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.kind;
        _h_ += (int)this.id;
        _h_ += this.readflag;
        _h_ += this.time.hashCode();
        _h_ += this.title.hashCode();
        _h_ += this.contentid;
        _h_ += this.content.hashCode();
        _h_ += this.awardid;
        _h_ += this.items.hashCode();
        _h_ += (int)this.awardexp;
        _h_ += (int)this.awardfushi;
        _h_ += (int)this.awardgold;
        _h_ += (int)this.awardmoney;
        _h_ += (int)this.awardvipexp;
        _h_ += this.npcid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.kind).append(",");
        _sb_.append(this.id).append(",");
        _sb_.append(this.readflag).append(",");
        _sb_.append("T").append(this.time.length()).append(",");
        _sb_.append("T").append(this.title.length()).append(",");
        _sb_.append(this.contentid).append(",");
        _sb_.append("T").append(this.content.length()).append(",");
        _sb_.append(this.awardid).append(",");
        _sb_.append(this.items).append(",");
        _sb_.append(this.awardexp).append(",");
        _sb_.append(this.awardfushi).append(",");
        _sb_.append(this.awardgold).append(",");
        _sb_.append(this.awardmoney).append(",");
        _sb_.append(this.awardvipexp).append(",");
        _sb_.append(this.npcid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
