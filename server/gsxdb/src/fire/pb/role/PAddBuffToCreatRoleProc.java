//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import fire.pb.PropConf.Battle;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.battle.Fighter;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.buff.continual.ConstantlyBuff;
import fire.pb.effect.RoleImpl;
import fire.pb.item.Module;
import fire.pb.item.SItemBuff;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.script.JavaScript;
import fire.script.SceneJSEngine;
import mkdb.Procedure;

public class PAddBuffToCreatRoleProc extends Procedure {
    private final long roleId;

    public PAddBuffToCreatRoleProc(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() throws Exception {
        BuffRoleImpl rolebuff = new BuffRoleImpl(this.roleId, false);
        ConstantlyBuff hpbuff = this.genBuff(32037, rolebuff);
        if (hpbuff != null) {
            rolebuff.addCBuffWithSP(hpbuff);
        }

        ConstantlyBuff mpbuff = this.genBuff(32038, rolebuff);
        if (mpbuff != null) {
            rolebuff.addCBuffWithSP(mpbuff);
        }

        return true;
    }

    private ConstantlyBuff genBuff(int itemid, BuffRoleImpl rolebuff) {
        SItemBuff sItemBuff = (SItemBuff)ConfigManager.getInstance().getConf(SItemBuff.class).get(itemid);
        if (sItemBuff == null) {
            return null;
        } else {
            BuffUnit buffArg = null;

            try {
                buffArg = Module.GetItemBuff(sItemBuff.outskill_id);
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (buffArg == null) {
                return null;
            } else {
                JavaScript js = null;
                js = (JavaScript)buffArg.effectJavascriptMap.get(81);
                if (js == null) {
                    js = (JavaScript)buffArg.effectJavascriptMap.get(101);
                }

                boolean bSp = false;
                if (js == null) {
                    js = (JavaScript)buffArg.effectJavascriptMap.get(121);
                    if (js != null) {
                        bSp = true;
                    }
                }

                if (js == null) {
                    throw new NullPointerException("配置有误");
                } else {
                    double val = js.eval(new SceneJSEngine(), (Fighter)null, (Fighter)null);
                    if (bSp) {
                        RoleImpl role = new RoleImpl(rolebuff.getRoleId(), false);
                        role.addSp((int)val, Battle.BATTLEENTER_SP_MAX);
                        SRefreshRoleData data = new SRefreshRoleData();
                        data.datas.put(120, (float)role.getSp());
                        Procedure.psendWhileCommit(rolebuff.getRoleId(), data);
                        return null;
                    } else {
                        ConstantlyBuff oldbuff = rolebuff.getBuff(buffArg.buffIndex);
                        long oldval = 0L;
                        if (oldbuff != null) {
                            oldval = oldbuff.getAmount();
                        }

                        ConstantlyBuff newbuff = fire.pb.buff.Module.getInstance().createConstantlyBuff(buffArg.buffIndex);
                        newbuff.setAmount((long)val + oldval);
                        return newbuff;
                    }
                }
            }
        }
    }
}
