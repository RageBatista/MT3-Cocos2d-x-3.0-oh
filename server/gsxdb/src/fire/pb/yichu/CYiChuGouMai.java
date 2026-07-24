//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.yichu;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import fire.pb.item.SShiZhuangYiChu;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;

public class CYiChuGouMai extends __CYiChuGouMai__ {
    public static final int PROTOCOL_TYPE = 800012;
    public int shizhuangid;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    Properties pro = xtable.Properties.get(roleId);
                    if (pro.getShizhuang().get(CYiChuGouMai.this.shizhuangid) != null && (Integer)pro.getShizhuang().get(CYiChuGouMai.this.shizhuangid) == CYiChuGouMai.this.shizhuangid) {
                        MessageMgr.sendMsgNotify(roleId, 201058, (List)null);
                        return false;
                    } else {
                        Pack bag = new Pack(roleId, false);
                        SShiZhuangYiChu sShiZhuangYiChu = (SShiZhuangYiChu)ConfigManager.getInstance().getConf(SShiZhuangYiChu.class).get(CYiChuGouMai.this.shizhuangid);
                        if (bag.getItemNum(sShiZhuangYiChu.cailiao, 0) < sShiZhuangYiChu.cailiaonum) {
                            MessageMgr.sendMsgNotify(roleId, 201056, (List)null);
                            return false;
                        } else if (bag.removeItemById(sShiZhuangYiChu.cailiao, sShiZhuangYiChu.cailiaonum, YYLoggerTuJingEnum.tujing_Value_fenjie, sShiZhuangYiChu.cailiao, "时装购买") == sShiZhuangYiChu.cailiaonum) {
                            pro.getShizhuang().put(CYiChuGouMai.this.shizhuangid, CYiChuGouMai.this.shizhuangid);
                            MessageMgr.sendMsgNotify(roleId, 201055, (List)null);
                            return true;
                        } else {
                            return true;
                        }
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 800012;
    }

    public CYiChuGouMai() {
    }

    public CYiChuGouMai(int _shizhuangid_) {
        this.shizhuangid = _shizhuangid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.shizhuangid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.shizhuangid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CYiChuGouMai) {
            CYiChuGouMai _o_ = (CYiChuGouMai)_o1_;
            return this.shizhuangid == _o_.shizhuangid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.shizhuangid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.shizhuangid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CYiChuGouMai _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.shizhuangid - _o_.shizhuangid;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}
