//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.jingmai;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SJingMaiMain extends __SJingMaiMain__ {
    public static final int PROTOCOL_TYPE = 800109;
    public int idx;
    public int qianyuandan;
    public int qiankundan;
    public int fangan;
    public int state;
    public HashMap<Integer, Integer> jingmais;
    public HashMap<Integer, XingChenItem> xingchen;

    protected void process() {
    }

    public int getType() {
        return 800109;
    }

    public SJingMaiMain() {
        this.jingmais = new HashMap();
        this.xingchen = new HashMap();
    }

    public SJingMaiMain(int _idx_, int _qianyuandan_, int _qiankundan_, int _fangan_, int _state_, HashMap<Integer, Integer> _jingmais_, HashMap<Integer, XingChenItem> _xingchen_) {
        this.idx = _idx_;
        this.qianyuandan = _qianyuandan_;
        this.qiankundan = _qiankundan_;
        this.fangan = _fangan_;
        this.state = _state_;
        this.jingmais = _jingmais_;
        this.xingchen = _xingchen_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.idx);
            _os_.marshal(this.qianyuandan);
            _os_.marshal(this.qiankundan);
            _os_.marshal(this.fangan);
            _os_.marshal(this.state);
            _os_.compact_uint32(this.jingmais.size());

            for(Map.Entry<Integer, Integer> _e_ : this.jingmais.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            _os_.compact_uint32(this.xingchen.size());

            for(Map.Entry<Integer, XingChenItem> _e_ : this.xingchen.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Marshal)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.idx = _os_.unmarshal_int();
        this.qianyuandan = _os_.unmarshal_int();
        this.qiankundan = _os_.unmarshal_int();
        this.fangan = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.jingmais.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            XingChenItem _v_ = new XingChenItem();
            _v_.unmarshal(_os_);
            this.xingchen.put(_k_, _v_);
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
        } else if (_o1_ instanceof SJingMaiMain) {
            SJingMaiMain _o_ = (SJingMaiMain)_o1_;
            if (this.idx != _o_.idx) {
                return false;
            } else if (this.qianyuandan != _o_.qianyuandan) {
                return false;
            } else if (this.qiankundan != _o_.qiankundan) {
                return false;
            } else if (this.fangan != _o_.fangan) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (!this.jingmais.equals(_o_.jingmais)) {
                return false;
            } else {
                return this.xingchen.equals(_o_.xingchen);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.idx;
        _h_ += this.qianyuandan;
        _h_ += this.qiankundan;
        _h_ += this.fangan;
        _h_ += this.state;
        _h_ += this.jingmais.hashCode();
        _h_ += this.xingchen.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.idx).append(",");
        _sb_.append(this.qianyuandan).append(",");
        _sb_.append(this.qiankundan).append(",");
        _sb_.append(this.fangan).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.jingmais).append(",");
        _sb_.append(this.xingchen).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
