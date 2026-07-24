//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import mkdb.Procedure;

public class CHuiShouItem extends __CHuiShouItem__ {
    public static final int PROTOCOL_TYPE = 800016;
    public int keyinpack;
    public int packid;
    public int huishou;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId != -1L) {
            (new Procedure() {
                public boolean process() {
                    Pack bag = new Pack(roleId, false);
                    ItemBase item = bag.getItem(CHuiShouItem.this.keyinpack);
                    if (item == null) {
                        return false;
                    } else {
                        SHuiShou sHuiShou = (SHuiShou)ConfigManager.getInstance().getConf(SHuiShou.class).get(item.getItemId());
                        if (sHuiShou == null) {
                            return false;
                        } else {
                            int count = 1;
                            int addcount = sHuiShou.huishouitemnum;
                            if (CHuiShouItem.this.huishou == 1) {
                                count = item.getNumber();
                                addcount = sHuiShou.huishouitemnum * item.getNumber();
                            }

                            if (bag.removeItemWithKey(CHuiShouItem.this.keyinpack, count, YYLoggerTuJingEnum.GM, 0, "回收物品") != count) {
                                MessageMgr.sendMsgNotify(roleId, 201070, (List)null);
                                return false;
                            } else if (bag.doAddItem(sHuiShou.huishouitemid, addcount, 0, 0, "回收物品返还", YYLoggerTuJingEnum.GM, 0) != addcount) {
                                MessageMgr.sendMsgNotify(roleId, 201070, (List)null);
                                return false;
                            } else {
                                MessageMgr.sendMsgNotify(roleId, 201069, (List)null);
                                return true;
                            }
                        }
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 800016;
    }

    public CHuiShouItem() {
    }

    public CHuiShouItem(int _huishou_, int _packid_, int _keyinpack_) {
        this.keyinpack = _keyinpack_;
        this.packid = _packid_;
        this.huishou = _huishou_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.huishou);
            _os_.marshal(this.packid);
            _os_.marshal(this.keyinpack);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.huishou = _os_.unmarshal_int();
        this.packid = _os_.unmarshal_int();
        this.keyinpack = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (!(_o1_ instanceof CHuiShouItem)) {
            return false;
        } else {
            CHuiShouItem _o_ = (CHuiShouItem)_o1_;
            return this.keyinpack == _o_.keyinpack && this.packid == _o_.packid && this.huishou == _o_.huishou;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.keyinpack;
        return _h_ + this.packid + this.huishou;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.keyinpack).append(",");
        _sb_.append(this.packid).append(",");
        _sb_.append(this.huishou).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CHuiShouItem _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.keyinpack - _o_.keyinpack;
            if (0 != _c_) {
                return _c_;
            } else {
                int _c_2 = this.packid - _o_.packid;
                if (0 != _c_2) {
                    return _c_2;
                } else {
                    int _c_3 = this.huishou - _o_.huishou;
                    return 0 != _c_3 ? _c_3 : _c_3;
                }
            }
        }
    }
}
