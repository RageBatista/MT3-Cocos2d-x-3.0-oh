//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.log.YYLogger;
import fire.log.beans.AddZhenfaExpBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.battle.FormationConfig;
import fire.pb.battle.SFormationConfig;
import fire.pb.common.SCommon;
import fire.pb.item.GroceryItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Procedure;
import xbean.FormBean;
import xbean.Pod;
import xtable.Locks;
import xtable.Roleid2teamid;

public class PUseFormationItem extends Procedure {
    private final long roleId;
    private final int formationId;
    private final int itemId;
    private final int itemnum;

    public PUseFormationItem(long roleId, int formId, int itemId, int itemnum) {
        this.roleId = roleId;
        this.formationId = formId;
        this.itemId = itemId;
        this.itemnum = itemnum;
    }

    protected boolean process() throws Exception {
        if (this.formationId > 0 && this.formationId <= 10) {
            int maxFormLevel = this.getMaxLevel();
            if (maxFormLevel < 0) {
                psend(this.roleId, new STeamError(57));
                TeamManager.logger.debug("CFormationMakeBook:光环等级已经最大了 " + this.roleId);
                return true;
            } else {
                GroceryItemShuXing itemconfig = (GroceryItemShuXing)Module.getInstance().getItemManager().getAttr(this.itemId);
                if (itemconfig == null) {
                    psend(this.roleId, new STeamError(56));
                    TeamManager.logger.debug("CFormationMakeBook:不知道的光环书 " + this.roleId);
                    return true;
                } else if (itemconfig.getTypeid() != 262 && itemconfig.getTypeid() != 278) {
                    psend(this.roleId, new STeamError(56));
                    TeamManager.logger.debug("CFormationMakeBook:不知道的光环书 " + this.roleId);
                    return true;
                } else {
                    Long teamId = Roleid2teamid.select(this.roleId);
                    Team team = null;
                    ArrayList<Long> roleids = new ArrayList();
                    if (teamId != null) {
                        team = new Team(teamId, false);
                        roleids.addAll(team.getAllMemberIds());
                        this.lock(Locks.ROLELOCK, roleids);
                    } else {
                        roleids.add(this.roleId);
                    }

                    PropRole prole = new PropRole(this.roleId, false);
                    Map<Integer, SFormationConfig> formations = ConfigManager.getInstance().getConf(SFormationConfig.class);
                    if (formations == null) {
                        psend(this.roleId, new STeamError(58));
                        TeamManager.logger.debug("CFormationMakeBook:光环id错误 " + this.roleId);
                        return true;
                    } else {
                        SFormationConfig config = (SFormationConfig)formations.get(this.formationId);
                        if (config == null) {
                            psend(this.roleId, new STeamError(58));
                            TeamManager.logger.debug("CFormationMakeBook:光环id错误 " + this.roleId);
                            return true;
                        } else {
                            Map<Integer, FormBean> formMap = prole.getFormtions();
                            FormBean fmb = (FormBean)formMap.get(this.formationId);
                            if (fmb == null) {
                                fmb = Pod.newFormBean();
                                fmb.setActivetimes(0);
                                fmb.setLevel(0);
                                fmb.setExp(0);
                                formMap.put(this.formationId, fmb);
                            }

                            int formlevel = fmb.getLevel();
                            if (formlevel >= this.getMaxLevel()) {
                                psend(this.roleId, new STeamError(57));
                                TeamManager.logger.debug("CFormationMakeBook:光环等级已经最大了 " + this.roleId);
                                return false;
                            } else {
                                Pack bag = new Pack(this.roleId, false);
                                int number = bag.removeItemById(this.itemId, this.itemnum, YYLoggerTuJingEnum.tujing_Value_guanghuanshengji, 0, "使用光环书或残卷");
                                if (number != this.itemnum) {
                                    psend(this.roleId, new STeamError(55));
                                    TeamManager.logger.debug("CFormationMakeBook:光环书不足 " + this.roleId);
                                    return false;
                                } else {
                                    boolean newformation = false;
                                    boolean levelup = false;
                                    if (formlevel == 0) {
                                        if (config.getMatchid() != this.itemId) {
                                            return false;
                                        }

                                        fmb.setLevel(1);
                                        fmb.setExp(0);
                                        newformation = true;
                                    } else {
                                        int addexp = this.calcAddExp(itemconfig, config) * this.itemnum;
                                        int nextformLevel = formlevel + 1;
                                        int bfexp = fmb.getExp();
                                        FormationConfig myformconfig = fire.pb.battle.Module.getInstance().getFormationById(this.formationId, nextformLevel);
                                        int levelupexp = myformconfig.getExp();

                                        int exp;
                                        FormationConfig myformconfignextlevel;
                                        for(exp = bfexp + addexp; exp >= levelupexp; levelupexp = myformconfignextlevel.getExp()) {
                                            levelup = true;
                                            exp -= levelupexp;
                                            ++formlevel;
                                            ++nextformLevel;
                                            if (formlevel >= maxFormLevel) {
                                                exp = 0;
                                                break;
                                            }

                                            myformconfignextlevel = fire.pb.battle.Module.getInstance().getFormationById(this.formationId, nextformLevel);
                                        }

                                        fmb.setExp(exp);
                                        fmb.setLevel(formlevel);
                                        AddZhenfaExpBean bean = new AddZhenfaExpBean(this.formationId, fmb.getLevel(), addexp, bfexp, fmb.getExp());
                                        YYLogger.addTeamzhenfaExpLog(this.roleId, bean);
                                    }

                                    Map<Integer, FormBean> out = new HashMap();
                                    out.put(this.formationId, fmb);
                                    this.notify(out);
                                    if (newformation) {
                                        List<String> parameters = new ArrayList();
                                        parameters.add(config.name);
                                        MessageMgr.sendMsgNotify(this.roleId, 160006, parameters);
                                    }

                                    if (!newformation && levelup) {
                                        SSetTeamFormation msg = new SSetTeamFormation();
                                        msg.formation = this.formationId;
                                        msg.formationlevel = formlevel;
                                        msg.msg = 1;

                                        for(Long roleid : roleids) {
                                            Procedure.psendWhileCommit(roleid, msg);
                                        }

                                        if (team != null && team.getTeamInfo().getFormation() == this.formationId) {
                                            team.changeFormationWithSP(this.formationId, formlevel, false);
                                        }
                                    }

                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        } else {
            psend(this.roleId, new STeamError(58));
            TeamManager.logger.debug("CFormationMakeBook:光环id错误 " + this.roleId);
            return true;
        }
    }

    private void notify(Map<Integer, FormBean> formMap) {
        SFormationsMap send = new SFormationsMap();
        Set<Integer> set = formMap.keySet();
        if (set.size() > 0) {
            for(int formId : set) {
                FormBean bean = (FormBean)formMap.get(formId);
                fire.pb.FormBean temp = new fire.pb.FormBean();
                temp.activetimes = bean.getActivetimes();
                temp.level = bean.getLevel();
                temp.exp = bean.getExp();
                send.formationmap.put(formId, temp);
            }
        }

        Procedure.psendWhileCommit(this.roleId, send);
    }

    private int getMaxLevel() {
        Map<Integer, SGuangHuanLevelup> formations = ConfigManager.getInstance().getConf(SGuangHuanLevelup.class);
        return formations == null ? -1 : formations.size();
    }

    public int calcAddExp(GroceryItemShuXing itemconfig, SFormationConfig formconfig) {
        if (formconfig.matchid == itemconfig.getId()) {
            return formconfig.matchidaddexp;
        } else if (itemconfig.getTypeid() == 262) {
            SCommon itemidconfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(131);
            int value = Integer.parseInt(itemidconfig.getValue());
            return value;
        } else {
            SCommon itemidconfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(132);
            int value = Integer.parseInt(itemidconfig.getValue());
            return value;
        }
    }
}
