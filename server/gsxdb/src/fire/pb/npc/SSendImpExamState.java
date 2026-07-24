//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSendImpExamState extends __SSendImpExamState__ {
    public static final int PROTOCOL_TYPE = 795463;
    public ImpExamBean impexamdata;
    public long historymintime;
    public int historymaxright;
    public String titlename;
    public byte lost;
    public long impexamusetime;

    protected void process() {
    }

    public int getType() {
        return 795463;
    }

    public SSendImpExamState() {
        this.impexamdata = new ImpExamBean();
        this.titlename = "";
    }

    public SSendImpExamState(ImpExamBean _impexamdata_, long _historymintime_, int _historymaxright_, String _titlename_, byte _lost_, long _impexamusetime_) {
        this.impexamdata = _impexamdata_;
        this.historymintime = _historymintime_;
        this.historymaxright = _historymaxright_;
        this.titlename = _titlename_;
        this.lost = _lost_;
        this.impexamusetime = _impexamusetime_;
    }

    public final boolean _validator_() {
        return this.impexamdata._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamdata);
            _os_.marshal(this.historymintime);
            _os_.marshal(this.historymaxright);
            _os_.marshal(this.titlename, "UTF-16LE");
            _os_.marshal(this.lost);
            _os_.marshal(this.impexamusetime);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamdata.unmarshal(_os_);
        this.historymintime = _os_.unmarshal_long();
        this.historymaxright = _os_.unmarshal_int();
        this.titlename = _os_.unmarshal_String("UTF-16LE");
        this.lost = _os_.unmarshal_byte();
        this.impexamusetime = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendImpExamState) {
            SSendImpExamState _o_ = (SSendImpExamState)_o1_;
            if (!this.impexamdata.equals(_o_.impexamdata)) {
                return false;
            } else if (this.historymintime != _o_.historymintime) {
                return false;
            } else if (this.historymaxright != _o_.historymaxright) {
                return false;
            } else if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else if (this.lost != _o_.lost) {
                return false;
            } else {
                return this.impexamusetime == _o_.impexamusetime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamdata.hashCode();
        _h_ += (int)this.historymintime;
        _h_ += this.historymaxright;
        _h_ += this.titlename.hashCode();
        _h_ += this.lost;
        _h_ += (int)this.impexamusetime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamdata).append(",");
        _sb_.append(this.historymintime).append(",");
        _sb_.append(this.historymaxright).append(",");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.lost).append(",");
        _sb_.append(this.impexamusetime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
