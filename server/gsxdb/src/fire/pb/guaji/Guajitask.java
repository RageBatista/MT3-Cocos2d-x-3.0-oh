//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.guaji;

import fire.pb.PropRole;
import fire.pb.activity.timernpc.PEnterNpcBattle;
import fire.pb.activity.timernpc.TimerNpcData;
import fire.pb.activity.timernpc.TimerNpcService;
import fire.pb.buff.Module;
import fire.pb.common.SCommon;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.map.Npc;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.mission.activelist.RoleLiveness;
import fire.pb.npc.SBattleToNpcError;
import fire.pb.npc.SNpcBattleTime;
import fire.pb.npc.SNpcGuaJi;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.timer.ScheduledFutureMap;
import fire.pb.title.Title;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.TimerTask;
import java.util.TreeMap;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import org.apache.log4j.Logger;
import mkdb.Executor;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.Pod;
import xbean.Properties;
import xbean.npcBattleInfoCol;
import xbean.timerNpcInfo;
import xbean.timerNpcInfoCol;
import xtable.Locks;
import xtable.Npcbattleinfo;
import xtable.Role2npcbattle;
import xtable.Roleid2battleid;
import xtable.Timernpcinfotable;

public class Guajitask extends TimerTask {
    private static final Logger LOGGER = Logger.getLogger(Guajitask.class);
    private final long roleId;
    private final List<Integer> leixing;
    private final int mapid;
    private int index;
    private int mapindex;
    private volatile long lastRunAt;

    public Guajitask(long roleId, List<Integer> typeList, int mapId) {
        this.roleId = roleId;
        this.leixing = typeList;
        this.mapid = mapId;
    }

    public void run() {
        long now = System.currentTimeMillis();
        if (this.lastRunAt != 0L) {
            long delay = now - this.lastRunAt;
            GuajiMetrics.recordSchedulerDelay(delay);
            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("Guaji 调度器 tick|roleId=" + this.roleId + "|delayMs=" + delay);
            }
        }
        this.lastRunAt = now;
        int currentMapId = this.mapid;
        final TreeMap guajiConfigMap = ConfigManager.getInstance().getConf(SNpcGuaJi.class);
        (new Procedure() {
            protected boolean process() {
                if (ScheduledFutureMap.getRoleFuture(Guajitask.this.roleId) == null) {
                    MessageMgr.psendMsgNotify(Guajitask.this.roleId, 201035, (List)null);
                    return false;
                } else if (Module.existState(Guajitask.this.roleId, 507004)) {
                    return false;
                } else {
                    Title title = new Title(Guajitask.this.roleId, true);
                    SCommon titleConfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(655);
                    int matchedTitleCount = 0;

                    for(int i = 0; i < titleConfig.getValue().split(";").length; ++i) {
                        if (title.roleHaveTitle(Integer.parseInt(titleConfig.getValue().split(";")[i]))) {
                            ++matchedTitleCount;
                        }
                    }

                    if (matchedTitleCount == 0) {
                        Guajitask.this.tingzhi("title_missing");
                        MessageMgr.psendMsgNotify(Guajitask.this.roleId, 201031, (List)null);
                        return false;
                    } else {
                        Role role = RoleManager.getInstance().getRoleByID(Guajitask.this.roleId);
                        final Properties properties = xtable.Properties.select(Guajitask.this.roleId);
                        SCommon offlineTitleConfig = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(657);
                        int offlineTitleCount = 0;

                        for(int j = 0; j < offlineTitleConfig.getValue().split(";").length; ++j) {
                            if (title.roleHaveTitle(Integer.parseInt(offlineTitleConfig.getValue().split(";")[j]))) {
                                ++offlineTitleCount;
                            }
                        }

                        if (offlineTitleCount == 0 && properties.getOnlinetime() <= properties.getOfflinetime()) {
                            Executor.getInstance().schedule(new Runnable() {
                                public void run() {
                                    if (properties.getOnlinetime() <= properties.getOfflinetime()) {
                                        Guajitask.this.tingzhi("离线超时");
                                    }

                                }
                            }, 60L, TimeUnit.SECONDS);
                        }

                        Team team = TeamManager.selectTeamByRoleId(Guajitask.this.roleId);
                        if (!team.isTeamLeader(Guajitask.this.roleId)) {
                            MessageMgr.sendMsgNotify(Guajitask.this.roleId, 201032, (List)null);
                            Guajitask.this.tingzhi("不是队长");
                            return false;
                        } else {
                            RoleLiveness roleLiveness = RoleLiveness.getRoleLiveness(Guajitask.this.roleId, true);
                            boolean allRewardsCollected = true;

                            for(int typeId : Guajitask.this.leixing) {
                                SNpcGuaJi npcGuajiConfig = (SNpcGuaJi)guajiConfigMap.get(typeId);
                                if (npcGuajiConfig != null && roleLiveness.getActiveNum(npcGuajiConfig.actid) < npcGuajiConfig.awardCnt) {
                                    allRewardsCollected = false;
                                    break;
                                }
                            }

                            if (allRewardsCollected) {
                                Guajitask.this.tingzhi("奖励限额");
                                MessageMgr.sendMsgNotify(Guajitask.this.roleId, 201037, (List)null);
                                return false;
                            } else {
                                if (Guajitask.this.index >= Guajitask.this.leixing.size()) {
                                    Guajitask.this.index = 0;
                                }

                                SNpcGuaJi currentNpcGuaji = (SNpcGuaJi)ConfigManager.getInstance().getConf(SNpcGuaJi.class).get(Guajitask.this.leixing.get(Guajitask.this.index));
                                if (currentNpcGuaji == null) {
                                    MessageMgr.sendMsgNotify(Guajitask.this.roleId, 201036, (List)null);
                                    Guajitask.this.tingzhi("配置缺失");
                                    return false;
                                } else {
                                    Pack pack = (Pack)fire.pb.item.Module.getInstance().getItemMaps(Guajitask.this.roleId, 1, false);
                                    if (pack.isFull()) {
                                        MessageMgr.psendMsgNotifyWhileRollback(Guajitask.this.roleId, 160062, (List)null);
                                        Guajitask.this.tingzhi("bag_full");
                                        return false;
                                    } else {
                                        String mapIdStr = currentNpcGuaji.mapid;
                                        String[] mapIdArray = mapIdStr.split(";");
                                        int[] mapIdIntArray = new int[mapIdArray.length];

                                        for(int k = 0; k < mapIdArray.length; ++k) {
                                            mapIdIntArray[k] = Integer.parseInt(mapIdArray[k]);
                                        }

                                        int targetMapId = mapIdIntArray[Guajitask.this.mapindex];
                                        if (null == Roleid2battleid.select(Guajitask.this.roleId)) {
                                            int maxAwardCount = currentNpcGuaji.awardCnt;
                                            int currentAwardCount = roleLiveness.getActiveNum(currentNpcGuaji.actid);
                                            int remainingCount = maxAwardCount - currentAwardCount;
                                            if (currentAwardCount < maxAwardCount) {
                                                if (role.getMapId() == targetMapId) {
                                                    ArrayList<Npc> npcList = new ArrayList<Npc>();
                                                    npcList.addAll(SceneNpcManager.getInstance().getNpcsByMap(targetMapId).values());

                                                    for(Npc npc : Guajitask.this.npca(npcList, currentNpcGuaji.npcs)) {
                                                        if (Guajitask.this.zhandou(npc.getNpcID(), npc.getNpcKey(), Guajitask.this.roleId)) {
                                                            int actId = TimerNpcService.getInstance().getActId(npc.getNpcID());
                                                            PEnterNpcBattle enterBattle = new PEnterNpcBattle(npc.getNpcID(), npc.getNpcKey(), actId, Guajitask.this.roleId);
                                                            ArrayList msgParams = new ArrayList();
                                                            msgParams.add(Integer.toString(currentAwardCount));
                                                            msgParams.add(Integer.toString(maxAwardCount));
                                                            msgParams.add(Integer.toString(remainingCount));
                                                            MessageMgr.sendMsgNotify(Guajitask.this.roleId, 201038, msgParams);
                                                            if (LOGGER.isInfoEnabled()) {
                                                                LOGGER.info("guaji_enter_battle|roleId=" + Guajitask.this.roleId + "|npcId=" + npc.getNpcID() + "|mapId=" + targetMapId + "|remaining=" + remainingCount);
                                                            }
                                                            return enterBattle.call();
                                                        }
                                                    }

                                                    Guajitask.this.mapindex++;
                                                    if (Guajitask.this.mapindex >= mapIdArray.length) {
                                                        Guajitask.this.index++;
                                                        Guajitask.this.mapindex = 0;
                                                    }
                                                } else {
                                                    fire.pb.scene.movable.Role sceneRole = fire.pb.scene.manager.RoleManager.getInstance().getRoleByID(Guajitask.this.roleId);
                                                    sceneRole.justGotoRandom((long)targetMapId, 516017);
                                                }
                                            } else {
                                                Guajitask.this.index++;
                                                Guajitask.this.mapindex = 0;
                                            }
                                        }

                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }).submit();
    }

    private void tingzhi() {
        this.tingzhi("未知");
    }

    private void tingzhi(String reason) {
        ScheduledFuture<?> scheduledFuture = ScheduledFutureMap.getRoleFuture(this.roleId);
        if (scheduledFuture != null) {
            scheduledFuture.cancel(true);
            ScheduledFutureMap.removeRoleFuture(this.roleId);
            MessageMgr.psendMsgNotify(this.roleId, 201035, (List)null);
            GuajiMetrics.recordStop(reason);
            if (LOGGER.isInfoEnabled()) {
                LOGGER.info("guaji_stop|reason=" + reason + "|roleId=" + this.roleId);
            }
        } else if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("guaji_stop_skip|reason=" + reason + "|roleId=" + this.roleId);
        }

    }

    private boolean zhandou(int npcId, long npcKey, long roleId) {
        int actId = TimerNpcService.getInstance().getActId(npcId);
        if (actId == -1) {
            return false;
        } else {
            TimerNpcData npcData = TimerNpcService.getInstance().getNpcData(actId);
            if (npcData == null) {
                return false;
            } else {
                int teamNumberCount = TimerNpcService.getInstance().getTeamNumberCount(actId);
                ArrayList<Long> memberIds = new ArrayList<Long>();
                if (teamNumberCount > 0) {
                    Team team = TeamManager.getTeamByRoleId(roleId);
                    if (team == null || team.getTeamLeaderId() != roleId) {
                        ArrayList msgParams = new ArrayList(1);
                        msgParams.add(String.valueOf(teamNumberCount));
                        MessageMgr.psendMsgNotify(roleId, 150522, npcId, msgParams);
                        return false;
                    }

                    memberIds.addAll(team.getNormalMemberIds());
                    Lockeys.lock(Lockeys.get(Locks.ROLELOCK, memberIds));
                    if (memberIds.size() < teamNumberCount) {
                        ArrayList msgParams = new ArrayList(1);
                        msgParams.add(String.valueOf(teamNumberCount));
                        MessageMgr.psendMsgNotify(roleId, 150522, npcId, msgParams);
                        return false;
                    }

                    ArrayList<String> lowLevelNames = new ArrayList<String>();
                    ArrayList<String> highLevelNames = new ArrayList<String>();

                    for(Long memberId : team.getNormalMemberIds()) {
                        PropRole propRole = new PropRole(memberId, true);
                        if (propRole.getLevel() < npcData.levelMin) {
                            lowLevelNames.add(propRole.getName());
                        } else if (propRole.getLevel() > npcData.levelMax) {
                            highLevelNames.add(propRole.getName());
                        }
                    }

                    if (lowLevelNames.size() > 0) {
                        StringBuffer nameBuffer = new StringBuffer();
                        byte index = 0;

                        for(String name : lowLevelNames) {
                            if (index != lowLevelNames.size() - 1) {
                                nameBuffer.append(name).append(",");
                            } else {
                                nameBuffer.append(name);
                            }
                        }

                        ArrayList msgParams = new ArrayList(2);
                        msgParams.add(nameBuffer.toString());
                        msgParams.add(String.valueOf(npcData.levelMin));

                        for(Long memberId : team.getNormalMemberIds()) {
                            MessageMgr.psendMsgNotifyWhileRollback(memberId, 150523, npcId, msgParams);
                        }

                        this.tingzhi("team_member_level_low");
                        return false;
                    }

                    if (highLevelNames.size() > 0) {
                        StringBuffer nameBuffer = new StringBuffer();
                        byte index = 0;

                        for(String name : highLevelNames) {
                            if (index != highLevelNames.size() - 1) {
                                nameBuffer.append(name).append(",");
                            } else {
                                nameBuffer.append(name);
                            }
                        }

                        ArrayList msgParams = new ArrayList(2);
                        msgParams.add(nameBuffer.toString());
                        msgParams.add(String.valueOf(npcData.levelMax));

                        for(Long memberId : team.getNormalMemberIds()) {
                            MessageMgr.psendMsgNotifyWhileRollback(memberId, 150525, npcId, msgParams);
                        }

                        this.tingzhi("team_member_level_high");
                        return false;
                    }
                } else {
                    Team team = TeamManager.getTeamByRoleId(roleId);
                    if (team == null || team.isAbsentMember(roleId)) {
                        PropRole propRole = new PropRole(roleId, true);
                        if (propRole.getLevel() > npcData.levelMax || propRole.getLevel() < npcData.levelMin) {
                            ArrayList msgParams = new ArrayList(1);
                            msgParams.add(String.valueOf(npcData.levelMin));
                            MessageMgr.psendMsgNotifyWhileRollback(roleId, 145496, npcId, msgParams);
                            return false;
                        }
                    }

                    if (team != null) {
                        memberIds.addAll(team.getNormalMemberIds());
                        Lockeys.lock(Lockeys.get(Locks.ROLELOCK, memberIds));
                        ArrayList<String> lowLevelNames = new ArrayList<String>();
                        ArrayList<String> highLevelNames = new ArrayList<String>();

                        for(Long memberId : team.getNormalMemberIds()) {
                            PropRole propRole = new PropRole(memberId, true);
                            if (propRole.getLevel() < npcData.levelMin) {
                                lowLevelNames.add(propRole.getName());
                            } else if (propRole.getLevel() > npcData.levelMax) {
                                highLevelNames.add(propRole.getName());
                            }
                        }

                        if (lowLevelNames.size() > 0) {
                            StringBuffer nameBuffer = new StringBuffer();
                            byte index = 0;

                            for(String name : lowLevelNames) {
                                if (index != lowLevelNames.size() - 1) {
                                    nameBuffer.append(name).append(",");
                                } else {
                                    nameBuffer.append(name);
                                }
                            }

                            ArrayList msgParams = new ArrayList(2);
                            msgParams.add(nameBuffer.toString());
                            msgParams.add(String.valueOf(npcData.levelMin));

                            for(Long memberId : team.getNormalMemberIds()) {
                                MessageMgr.psendMsgNotifyWhileRollback(memberId, 150523, npcId, msgParams);
                            }

                            this.tingzhi("team_member_level_low");
                            return false;
                        }

                        if (highLevelNames.size() > 0) {
                            StringBuffer nameBuffer = new StringBuffer();
                            byte index = 0;

                            for(String name : highLevelNames) {
                                if (index != highLevelNames.size() - 1) {
                                    nameBuffer.append(name).append(",");
                                } else {
                                    nameBuffer.append(name);
                                }
                            }

                            ArrayList msgParams = new ArrayList(2);
                            msgParams.add(nameBuffer.toString());
                            msgParams.add(String.valueOf(npcData.levelMax));

                            for(Long memberId : team.getNormalMemberIds()) {
                                MessageMgr.psendMsgNotifyWhileRollback(memberId, 150525, npcId, msgParams);
                            }

                            this.tingzhi("team_member_level_high");
                            return false;
                        }
                    }
                }

                if (npcData.havetimes == 1) {
                    boolean hasAwardTimes = false;

                    for(Long memberId : memberIds) {
                        if (TimerNpcService.checkBattleAwardTimes(memberId, actId)) {
                            hasAwardTimes = true;
                            break;
                        }
                    }

                    if (!hasAwardTimes) {
                        for(Long memberId : memberIds) {
                            MessageMgr.psendMsgNotifyWhileRollback(memberId, 170054, (List)null);
                        }

                        return false;
                    }
                }

                timerNpcInfoCol npcInfoCol = Timernpcinfotable.get(actId);
                if (npcInfoCol == null) {
                    return false;
                } else if (!npcInfoCol.getNpcinfo().containsKey(npcKey)) {
                    return false;
                } else {
                    timerNpcInfo npcInfo = (timerNpcInfo)npcInfoCol.getNpcinfo().get(npcKey);
                    if (npcInfo == null) {
                        return false;
                    } else if (npcInfo.getNpcstatus() == 2) {
                        return false;
                    } else {
                        if (npcData.battletime > 1) {
                            if (npcInfo.getBattletime() >= npcData.battletime) {
                                return false;
                            }
                        } else if (npcInfo.getNpcstatus() == 1) {
                            return false;
                        }

                        if (npcData.match == 1) {
                            long currentTime = System.currentTimeMillis();
                            if (currentTime - npcInfo.getCreatetime() < (long)(npcData.matchsec * 1000)) {
                                npcBattleInfoCol battleInfoCol = Npcbattleinfo.get(npcKey);
                                if (battleInfoCol == null) {
                                    battleInfoCol = Pod.newnpcBattleInfoCol();
                                    Npcbattleinfo.insert(npcKey, battleInfoCol);
                                }

                                battleInfoCol.getBattleroles().put(roleId, memberIds.size());
                                Long previousNpcKey = Role2npcbattle.select(roleId);
                                if (previousNpcKey != null) {
                                    npcBattleInfoCol previousBattleInfoCol = Npcbattleinfo.get(previousNpcKey);
                                    if (previousBattleInfoCol != null) {
                                        previousBattleInfoCol.getBattleroles().remove(roleId);
                                    }

                                    Role2npcbattle.remove(roleId);
                                }

                                Role2npcbattle.insert(roleId, npcKey);
                                long remainingTime = npcInfo.getCreatetime() + (long)(npcData.matchsec * 1000) - currentTime;
                                Procedure.psendWhileCommit(memberIds, new SNpcBattleTime(npcId, npcKey, (long)(npcData.matchsec * 1000), remainingTime));
                                return false;
                            }

                            npcBattleInfoCol battleInfoCol = Npcbattleinfo.get(npcKey);
                            if (battleInfoCol != null && battleInfoCol.getBattleroles().size() != 0) {
                            }
                        }

                        return true;
                    }
                }
            }
        }
    }

    private void sendErrorResponse(int errorCode, long roleId) {
        SBattleToNpcError errorResponse = new SBattleToNpcError();
        errorResponse.battleerror = errorCode;
        Procedure.psendWhileCommit(roleId, errorResponse);
    }

    private Collection<Npc> npca(Collection<Npc> npcCollection, String npcIds) {
        ArrayList<Npc> matchedNpcs = new ArrayList<Npc>();

        for(Npc npc : npcCollection) {
            if (!npcIds.contains(";")) {
                if (npc.getNpcID() == Integer.parseInt(npcIds)) {
                    matchedNpcs.add(npc);
                }
            } else {
                for(int i = 0; i < npcIds.split(";").length; ++i) {
                    if (npc.getNpcID() == Integer.parseInt(npcIds.split(";")[i])) {
                        matchedNpcs.add(npc);
                    }
                }
            }
        }

        return matchedNpcs;
    }
}
