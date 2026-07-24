//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SSendImpExamProv extends __SSendImpExamProv__ {
    public static final int PROTOCOL_TYPE = 795462;
    public ImpExamBean impexamdata;
    public byte lost;
    public String titlename;
    public HashMap<Integer, Integer> rightmap;

    protected void process() {
    }

    public int getType() {
        return 795462;
    }

    public SSendImpExamProv() {
        this.impexamdata = new ImpExamBean();
        this.titlename = "";
        this.rightmap = new HashMap();
    }

    public SSendImpExamProv(ImpExamBean _impexamdata_, byte _lost_, String _titlename_, HashMap<Integer, Integer> _rightmap_) {
        this.impexamdata = _impexamdata_;
        this.lost = _lost_;
        this.titlename = _titlename_;
        this.rightmap = _rightmap_;
    }

    public final boolean _validator_() {
        return this.impexamdata._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.impexamdata);
            _os_.marshal(this.lost);
            _os_.marshal(this.titlename, "UTF-16LE");
            _os_.compact_uint32(this.rightmap.size());

            for(Map.Entry<Integer, Integer> _e_ : this.rightmap.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.impexamdata.unmarshal(_os_);
        this.lost = _os_.unmarshal_byte();
        this.titlename = _os_.unmarshal_String("UTF-16LE");

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.rightmap.put(_k_, _v_);
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
        } else if (_o1_ instanceof SSendImpExamProv) {
            SSendImpExamProv _o_ = (SSendImpExamProv)_o1_;
            if (!this.impexamdata.equals(_o_.impexamdata)) {
                return false;
            } else if (this.lost != _o_.lost) {
                return false;
            } else if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else {
                return this.rightmap.equals(_o_.rightmap);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.impexamdata.hashCode();
        _h_ += this.lost;
        _h_ += this.titlename.hashCode();
        _h_ += this.rightmap.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.impexamdata).append(",");
        _sb_.append(this.lost).append(",");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.rightmap).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
