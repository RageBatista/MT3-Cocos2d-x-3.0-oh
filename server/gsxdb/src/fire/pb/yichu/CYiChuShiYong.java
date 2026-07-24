//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.yichu;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.msp.task.GChangeShape;
import fire.pb.GsClient;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.item.SShiZhuangYiChu;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.skill.Result;
import fire.pb.skill.SkillRole;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.BattleInfo;
import xbean.Pod;
import xbean.Properties;
import xbean.TransfromByItemData;
import xtable.Transformbyitem;

public class CYiChuShiYong extends __CYiChuShiYong__ {
    public static final int PROTOCOL_TYPE = 800011;
    private static final Logger logger = Logger.getLogger("SYSTEM");
    public int shizhuangid;
    public int moxing;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            final Map<Integer, SShiZhuangYiChu> sRoleRColorConfig = ConfigManager.getInstance().getConf(SShiZhuangYiChu.class);
            (new Procedure() {
                protected boolean process() {
                    BuffAgent buffRole = new BuffRoleImpl(roleId, false);

                    for(Map.Entry<Integer, SShiZhuangYiChu> integerSShiZhuangYiChuEntry : sRoleRColorConfig.entrySet()) {
                        if (((SShiZhuangYiChu)integerSShiZhuangYiChuEntry.getValue()).moxing == CYiChuShiYong.this.moxing) {
                            buffRole.removeCBuff(((SShiZhuangYiChu)integerSShiZhuangYiChuEntry.getValue()).buff);
                            SkillRole spet = new SkillRole(roleId);
                            Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                            buffRole.psendSBuffChangeResult(result);
                        }
                    }

                    Properties pro = xtable.Properties.get(roleId);
                    TransfromByItemData transdata = Transformbyitem.get(roleId);
                    if (transdata == null) {
                        CYiChuShiYong.logger.info("角色[" + roleId + "] TransfromByItemData数据为空，自动创建新的数据");
                        transdata = Pod.newTransfromByItemData();
                        Transformbyitem.insert(roleId, transdata);
                    }

                    SShiZhuangYiChu sShiZhuangYiChu = (SShiZhuangYiChu)ConfigManager.getInstance().getConf(SShiZhuangYiChu.class).get(pro.getShizhuang().get(CYiChuShiYong.this.shizhuangid));
                    if (sShiZhuangYiChu == null) {
                        CYiChuShiYong.logger.error("角色[" + roleId + "] 时装配置不存在，时装ID=" + CYiChuShiYong.this.shizhuangid);
                        return false;
                    } else {
                        pro.setShape(sShiZhuangYiChu.moxing);
                        GChangeShape send2Scene = new GChangeShape();
                        send2Scene.playerid = roleId;
                        transdata.setTransformid(sShiZhuangYiChu.moxing);
                        send2Scene.changetype = 0;
                        send2Scene.shape = pro.getShape();
                        GsClient.pSendWhileCommit(send2Scene);
                        SChangeYiChu sshizhuang = new SChangeYiChu();
                        sshizhuang.shape = pro.getShape();
                        Procedure.psendWhileCommit(roleId, sshizhuang);
                        MessageMgr.psendMsgNotify(roleId, 201057, (List)null);
                        MessageMgr.psendSystemMessageToRole(roleId, 201057, (List)null);
                        buffRole.addCBuffWithSP(sShiZhuangYiChu.buff);
                        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(roleId));
                        return true;
                    }
                }
            }).submit();
        }

    }

    public int getType() {
        return 800011;
    }

    public CYiChuShiYong() {
    }

    public CYiChuShiYong(int _shizhuangid_) {
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
        } else if (_o1_ instanceof CYiChuShiYong) {
            CYiChuShiYong _o_ = (CYiChuShiYong)_o1_;
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

    public int compareTo(CYiChuShiYong _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.shizhuangid - _o_.shizhuangid;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}
