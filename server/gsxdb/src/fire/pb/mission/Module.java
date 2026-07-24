//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import fire.msp.task.GScenarioQuestUseItemVerifyPos;
import fire.msp.task.MScenarioQuestUseItemVerifyPosSucc;
import fire.pb.GsClient;
import fire.pb.circletask.CircTask;
import fire.pb.circletask.CircleTask;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.circletask.PClearCircleTask;
import fire.pb.circletask.anye.RoleAnYeTask;
import fire.pb.clan.ClanUtils;
import fire.pb.course.CourseManager;
import fire.pb.event.AddGemToEquip;
import fire.pb.event.BagItemChange;
import fire.pb.event.BattleEndEvent;
import fire.pb.event.BuyItemEvent;
import fire.pb.event.CircleTaskCompleteEvent;
import fire.pb.event.EndMinigameEvent;
import fire.pb.event.EnterPetLuckEvent;
import fire.pb.event.EnterWorldEvent;
import fire.pb.event.EquipItemEvent;
import fire.pb.event.Event;
import fire.pb.event.EventHandler;
import fire.pb.event.FactionCreateOrJoinEvent;
import fire.pb.event.ForgeDecorationEvent;
import fire.pb.event.GetMasterEvent;
import fire.pb.event.JoinCampEvent;
import fire.pb.event.LevelBreakEvent;
import fire.pb.event.LevelContinueEvent;
import fire.pb.event.LevelupEvent;
import fire.pb.event.MissionCompleteEvent;
import fire.pb.event.MoneyChangeEvent;
import fire.pb.event.OutBattleEvent;
import fire.pb.event.PetColumnChange;
import fire.pb.event.PetStarEvent;
import fire.pb.event.Poster;
import fire.pb.event.RefineEquipEvent;
import fire.pb.event.ReleaseApprenticeInfoEvent;
import fire.pb.event.ReleaseInfoEvent;
import fire.pb.event.ReleaseJianghuzhaoji;
import fire.pb.event.SetFightPetEvent;
import fire.pb.event.SetProtectPasswordEvent;
import fire.pb.event.UnequipItemEvent;
import fire.pb.event.UpdateInbornLevel;
import fire.pb.event.VisitSite;
import fire.pb.event.WinUndeadChallangeEvent;
import fire.pb.item.CombineItemEvent;
import fire.pb.item.Commontext;
import fire.pb.item.EnterBingFengInstEvent;
import fire.pb.item.EnterJingYingInstEvent;
import fire.pb.item.EquipMakeEvent;
import fire.pb.item.RoleAddPointEvent;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.main.ModuleInterface;
import fire.pb.main.ModuleManager;
import fire.pb.main.ReloadResult;
import fire.pb.mission.activelist.RoleLivenessManager;
import fire.pb.mission.util.ItemMissionListener;
import fire.pb.mission.util.PetMissionListener;
import fire.pb.npc.SGatherConfig;
import fire.pb.school.School;
import fire.pb.talk.MessageMgr;
import fire.pb.title.Title;
import fire.pb.util.DateValidate;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Lockeys;
import mkdb.Procedure;
import mkdb.TTable;
import mkdb.Transaction;
import org.apache.log4j.Logger;
import xbean.ChargeHistory;
import xbean.ChargeOrder;
import xbean.CircleTaskInfo;
import xbean.ClanInfo;
import xbean.Pod;
import xbean.Track;
import xbean.TrackedMission;
import xtable.Chargehistory;
import xtable.Chargeorder;
import xtable.Locks;
import xtable.Platorderhistroy;
import xtable.Properties;
import xtable.Trackedmission;

public class Module implements ModuleInterface, EventHandler {
    public static final String MODULE_NAME = "mission";
    public static final Logger logger = Logger.getLogger("TASK");
    private final ItemMissionListener itemmissionlistener = new ItemMissionListener();
    private final PetMissionListener petmissionlistener = new PetMissionListener();
    private boolean chargeClear = true;

    public static Module getInstance() {
        return (Module)ModuleManager.getInstance().getModuleByName("mission");
    }

    public void enterWorldOK(final long roleid) {
        (new Procedure() {
            protected boolean process() {
                (new MissionColumn(roleid, false)).afterEnterWorld();
                return true;
            }
        }).submit();
    }

    public boolean checkGather(long roleid, SGatherConfig conf) {
        MissionColumn sml = new MissionColumn(roleid, true);

        for(int mission : conf.tasks) {
            if (sml.getMission(mission) != null) {
                return true;
            }
        }

        return false;
    }

    public void exit() {
    }

    public void getCanAcceptMission4TuPo(long roleid, List<Integer> quests, int level) {
        quests.clear();

        for(QuestCanAcceptList quest : MissionManager.getInstance().getCanAcceptMissionMap().values()) {
            if (UtilHelper.isBranchScenarioMission(quest.id)) {
                if (UtilHelper.isTuPoMission(quest.id) && quest.任务等级min == level && quest.任务等级min == quest.任务等级max) {
                    Integer roleLevel = Properties.selectLevel(roleid);
                    if (roleLevel != null && roleLevel == quest.任务等级min && !quests.contains(quest.id)) {
                        quests.add(quest.id);
                    }
                }
            } else {
                this.getCanAcceptMission(roleid, quests, quest);
            }
        }

        Collections.sort(quests);
    }

    public void getCanAcceptMission(long roleid, List<Integer> quests) {
        quests.clear();
        MissionColumn sml = new MissionColumn(roleid, true);

        for(QuestCanAcceptList quest : MissionManager.getInstance().getCanAcceptMissionMap().values()) {
            if (UtilHelper.isBranchScenarioMission(quest.id)) {
                if (UtilHelper.isTuPoMission(quest.id) && quest.任务等级min == quest.任务等级max) {
                    Integer roleLevel = Properties.selectLevel(roleid);
                    if (roleLevel != null && roleLevel == quest.任务等级min) {
                        RoleMission task = sml.getMission(quest.id);
                        if (task == null && !sml.hasTuPoMission()) {
                            int taskline = UtilHelper.getMissionLineid(quest.id);
                            if (sml.getMissionByLineid(taskline) == null) {
                                Map<Integer, Integer> tupotips = Properties.selectTupotips(roleid);
                                Integer st = (Integer)tupotips.get(quest.任务等级min);
                                if (st != null && st == 1 && !quests.contains(quest.id)) {
                                    quests.add(quest.id);
                                }
                            }
                        }
                    }
                }
            } else {
                this.getCanAcceptMission(roleid, quests, quest);
            }
        }

        Collections.sort(quests);
    }

    public void getCanAcceptMission4Abandon(long roleid, List<Integer> quests) {
        quests.clear();
        MissionColumn sml = new MissionColumn(roleid, true);

        for(QuestCanAcceptList quest : MissionManager.getInstance().getCanAcceptMissionMap().values()) {
            if (UtilHelper.isBranchScenarioMission(quest.id)) {
                if (UtilHelper.isTuPoMission(quest.id) && quest.任务等级min == quest.任务等级max) {
                    Integer roleLevel = Properties.selectLevel(roleid);
                    if (roleLevel != null && roleLevel == quest.任务等级min) {
                        RoleMission task = sml.getMission(quest.id);
                        if (task == null || task.getState() == -1) {
                            Map<Integer, Integer> tupotips = Properties.selectTupotips(roleid);
                            Integer st = (Integer)tupotips.get(quest.任务等级min);
                            if (st != null && st == 1 && !quests.contains(quest.id)) {
                                quests.add(quest.id);
                            }
                        }
                    }
                }
            } else {
                this.getCanAcceptMission(roleid, quests, quest);
            }
        }

        Collections.sort(quests);
    }

    private void getCanAcceptMission(long roleid, List<Integer> quests, QuestCanAcceptList quest) {
        Integer roleLevel = Properties.selectLevel(roleid);
        if (roleLevel != null) {
            if (quest.任务等级min <= roleLevel && roleLevel <= quest.任务等级max) {
                if (UtilHelper.isSpecialQuest(quest.id)) {
                    CircleTask sq = new CircleTask(roleid, true);
                    if (sq.getSpecialQuestState(quest.id) == -1) {
                        quests.add(quest.id);
                    } else {
                        CircleTaskInfo sqinfo = sq.getSpecialQuestInfo(quest.id);
                        if (sqinfo.getQueststate() == 5 || sqinfo.getQueststate() == 1 || sqinfo.getQueststate() == 2 || sqinfo.getQueststate() == 0) {
                            CircTask ct = CircleTaskManager.getInstance().getCircTask(sqinfo.getId());
                            if (ct.totaltime == 0) {
                                quests.add(quest.id);
                            } else {
                                int circle = ct.getCycle();
                                long now = System.currentTimeMillis();
                                switch (circle) {
                                    case 1:
                                        if (!DateValidate.inTheSameDay(sqinfo.getTakequesttime(), now)) {
                                            quests.add(quest.id);
                                        } else {
                                            int sumtime = sqinfo.getSumnum();
                                            if (sumtime < ct.totaltime) {
                                                quests.add(quest.id);
                                            }
                                        }
                                        break;
                                    case 2:
                                        if (!DateValidate.inTheSameWeek(sqinfo.getTakequesttime(), now)) {
                                            quests.add(quest.id);
                                        } else {
                                            int sumtime = sqinfo.getSumnum();
                                            if (sumtime < ct.totaltime) {
                                                quests.add(quest.id);
                                            }
                                        }
                                        break;
                                    case 3:
                                        if (!DateValidate.inTheSameMonth(sqinfo.getTakequesttime(), now)) {
                                            quests.add(quest.id);
                                        } else {
                                            int sumtime = sqinfo.getSumnum();
                                            if (sumtime < ct.totaltime) {
                                                quests.add(quest.id);
                                            }
                                        }
                                }
                            }
                        }
                    }
                } else {
                    quests.add(quest.id);
                }
            }

        }
    }

    public int hasUnfinishedFairylandMission(long roleid) {
        for(RoleMission sm : new MissionColumn(roleid, true)) {
            if (sm != null && sm.isFairylandQuest() && sm.getState() != 1) {
                return sm.getId();
            }
        }

        return 0;
    }

    public void init() throws Exception {
        logger.info("task模块初始化开始");
        ConfigManager cm = ConfigManager.getInstance();
        CircleTaskManager.getInstance();
        MissionManager.getInstance().init(cm);
        Poster.getPoster().listenEvent(this, EquipItemEvent.class);
        Poster.getPoster().listenEvent(this, UnequipItemEvent.class);
        Poster.getPoster().listenEvent(this, SetFightPetEvent.class);
        Poster.getPoster().listenEvent(this, LevelupEvent.class);
        Poster.getPoster().listenEvent(this, BuyItemEvent.class);
        Poster.getPoster().listenEvent(this, EnterWorldEvent.class);
        Poster.getPoster().listenEvent(this, OutBattleEvent.class);
        Poster.getPoster().listenEvent(this, BattleEndEvent.class);
        Poster.getPoster().listenEvent(this, BagItemChange.class);
        Poster.getPoster().listenEvent(this, PetColumnChange.class);
        Poster.getPoster().listenEvent(this, MissionCompleteEvent.class);
        Poster.getPoster().listenEvent(this, CircleTaskCompleteEvent.class);
        Poster.getPoster().listenEvent(this, UpdateInbornLevel.class);
        Poster.getPoster().listenEvent(this, ReleaseInfoEvent.class);
        Poster.getPoster().listenEvent(this, ReleaseJianghuzhaoji.class);
        Poster.getPoster().listenEvent(this, GetMasterEvent.class);
        Poster.getPoster().listenEvent(this, EndMinigameEvent.class);
        Poster.getPoster().listenEvent(this, WinUndeadChallangeEvent.class);
        Poster.getPoster().listenEvent(this, MoneyChangeEvent.class);
        Poster.getPoster().listenEvent(this, AddGemToEquip.class);
        Poster.getPoster().listenEvent(this, RefineEquipEvent.class);
        Poster.getPoster().listenEvent(this, ReleaseApprenticeInfoEvent.class);
        Poster.getPoster().listenEvent(this, VisitSite.class);
        Poster.getPoster().listenEvent(this, PetStarEvent.class);
        Poster.getPoster().listenEvent(this, JoinCampEvent.class);
        Poster.getPoster().listenEvent(this, EnterPetLuckEvent.class);
        Poster.getPoster().listenEvent(this, SetProtectPasswordEvent.class);
        Poster.getPoster().listenEvent(this, CombineItemEvent.class);
        Poster.getPoster().listenEvent(this, EquipMakeEvent.class);
        Poster.getPoster().listenEvent(this, RoleAddPointEvent.class);
        Poster.getPoster().listenEvent(this, ForgeDecorationEvent.class);
        Poster.getPoster().listenEvent(this, EnterJingYingInstEvent.class);
        Poster.getPoster().listenEvent(this, EnterBingFengInstEvent.class);
        Poster.getPoster().listenEvent(this, FactionCreateOrJoinEvent.class);
        Poster.getPoster().listenEvent(this, LevelBreakEvent.class);
        Poster.getPoster().listenEvent(this, LevelContinueEvent.class);
        RoleLivenessManager.getInstance().init();
        logger.info("task模块初始化完成");
        CourseManager.getInstance().Init();
        if (this.chargeClear) {
            this.chargeDataClear();
            this.chargeHistoryDataClear();
            this.platOrderHistroyClear();
            this.chargeClear = false;
        }

    }

    private void platOrderHistroyClear() {
        logger.info("开始清理过期平台充值订单历史...");
        final Set<String> platorders = new HashSet();
        Platorderhistroy.getTable().browse(new TTable.IWalk<String, Long>() {
            public boolean onRecord(String platsn, Long time) {
                platorders.add(platsn);
                return true;
            }
        });
        logger.info("开始清理过期平台充值订单历史...size=" + platorders.size());
        Procedure proc = new Procedure() {
            protected boolean process() {
                if (platorders.isEmpty()) {
                    return true;
                } else {
                    this.lock(Lockeys.get(Locks.PLATORDERHISTROY, platorders));
                    long now = System.currentTimeMillis();

                    for(String platsn : platorders) {
                        Long historytime = Platorderhistroy.select(platsn);
                        if (Math.abs(now - historytime) >= 604800000L) {
                            Platorderhistroy.remove(platsn);
                        }
                    }

                    Module.logger.info("完成清理过期无效充值订单.");
                    return true;
                }
            }
        };
        if (Transaction.current() == null) {
            proc.submit();
        } else {
            Procedure.pexecute(proc);
        }

    }

    private void chargeHistoryDataClear() {
        logger.info("开始清理过期无效充值订单历史...");
        final Set<Integer> userids = new HashSet();
        Chargehistory.getTable().browse(new TTable.IWalk<Integer, ChargeHistory>() {
            public boolean onRecord(Integer userid, ChargeHistory value) {
                userids.add(userid);
                return true;
            }
        });
        logger.info("开始清理过期无效充值订单历史...size=" + userids.size());
        Procedure proc = new Procedure() {
            protected boolean process() {
                if (userids.isEmpty()) {
                    return true;
                } else {
                    this.lock(Lockeys.get(Locks.USERLOCK, userids));
                    long now = System.currentTimeMillis();

                    for(int userid : userids) {
                        ChargeHistory ch = Chargehistory.get(userid);
                        Set<Long> delChargeSns = new HashSet();

                        for(Map.Entry<Long, ChargeOrder> en : ch.getCharges().entrySet()) {
                            if (!DateValidate.inTheSameWeek(now, ((ChargeOrder)en.getValue()).getCreatetime()) && ((ChargeOrder)en.getValue()).getStatus() == 1) {
                                delChargeSns.add(en.getKey());
                            }
                        }

                        for(long csn : delChargeSns) {
                            ch.getCharges().remove(csn);
                        }
                    }

                    Module.logger.info("完成清理过期无效充值订单历史.");
                    return true;
                }
            }
        };
        if (Transaction.current() == null) {
            proc.submit();
        } else {
            Procedure.pexecute(proc);
        }

    }

    private void chargeDataClear() {
        logger.info("开始清理过期无效充值订单...");
        final Set<Long> chargeSns = new HashSet();
        Chargeorder.getTable().browse(new TTable.IWalk<Long, ChargeOrder>() {
            public boolean onRecord(Long chargeSn, ChargeOrder value) {
                chargeSns.add(chargeSn);
                return true;
            }
        });
        logger.info("开始清理过期无效充值订单...size=" + chargeSns.size());
        Procedure proc = new Procedure() {
            protected boolean process() {
                if (chargeSns.isEmpty()) {
                    return true;
                } else {
                    this.lock(Lockeys.get(Locks.CHARGEORDER, chargeSns));
                    long now = System.currentTimeMillis();

                    for(long chargeSn : chargeSns) {
                        long chargeTime = Chargeorder.selectCreatetime(chargeSn);
                        if (!DateValidate.inTheSameWeek(now, chargeTime)) {
                            Chargeorder.remove(chargeSn);
                        }
                    }

                    Module.logger.info("完成清理过期无效充值订单.");
                    return true;
                }
            }
        };
        if (Transaction.current() == null) {
            proc.submit();
        } else {
            Procedure.pexecute(proc);
        }

    }

    public void onEvent(final Event e) {
        PMissionProc p = new PMissionProc() {
            protected boolean missionExecute() {
                if (e instanceof EnterWorldEvent) {
                    Module.this.sendScenarioMission(e.getRoleid());
                    Module.this.sendAllCanAcceptMission(e.getRoleid());
                    Module.this.sendAllAcceptedMission(e.getRoleid());
                    Module.this.sendTracked(e.getRoleid());
                    return true;
                } else {
                    (new MissionColumn(e.getRoleid(), false)).onEvent(e);
                    if (e instanceof BagItemChange) {
                        BagItemChange event = (BagItemChange)e;
                        Module.this.itemmissionlistener.onChanged(event.getRoleid(), event.getItemid());
                    } else if (e instanceof PetColumnChange) {
                        PetColumnChange event = (PetColumnChange)e;
                        Module.this.petmissionlistener.onPetColumnChange(event.getRoleid(), event.getPetid());
                    } else if (!(e instanceof BattleEndEvent)) {
                        if (e instanceof SetFightPetEvent) {
                            SetFightPetEvent event = (SetFightPetEvent)e;
                            Module.this.petmissionlistener.onPetColumnChange(event.getRoleid(), event.getPetid());
                        } else if (e instanceof MissionCompleteEvent) {
                            MissionCompleteEvent event = (MissionCompleteEvent)e;
                            int id = event.getMissionID();
                            int level = 0;
                            if (id == 1120001) {
                                level = 1;
                            } else if (id == 1130001) {
                                level = 2;
                            } else if (id == 1140001) {
                                level = 3;
                            }

                            if (level != 0) {
                                long roleid = event.getRoleid();
                                xbean.Properties prop = Properties.select(roleid);
                                if (prop != null) {
                                    School s = fire.pb.school.SchoolManager.getSchoolById(prop.getSchool());
                                    int titleID = fire.pb.school.SchoolManager.getTitleId(s, level, prop.getSex());
                                    Title title = new Title(roleid, false);
                                    if (!title.roleHaveTitle(titleID)) {
                                        Title.addTitle(roleid, titleID, "", -1L);
                                    }
                                }
                            }
                        }
                    }

                    return true;
                }
            }
        };
        PMissionProc p2 = null;
        if (e instanceof EnterWorldEvent) {
            p2 = new PMissionProc() {
                protected boolean missionExecute() {
                    RoleAnYeTask.sendAllAnYeTask(e.getRoleid());
                    return true;
                }
            };
        }

        if (Transaction.current() == null) {
            p.submit();
            if (p2 != null) {
                p2.submit();
            }
        } else {
            p.call();
            if (p2 != null) {
                p2.call();
            }
        }

    }

    public Commontext.UseResult onUseMissionItem(long roleid, int itemid) {
        logger.info("角色[" + roleid + "]使用任务道具[" + itemid + "]");

        for(RoleMission mission : new MissionColumn(roleid, false)) {
            if (mission.getState() != -1 && mission.getConf() != null && UtilHelper.getMissionExeType(mission.getConf().exeIndo.missionType) == 2) {
                MissionConfig conf = mission.getConf();
                if (conf.exeIndo.useItemID == itemid) {
                    if (conf.exeIndo.leftPos == 0 && conf.exeIndo.rightPos == 0 && conf.exeIndo.topPos == 0 && conf.exeIndo.bottomPos == 0) {
                        boolean useSucc = MScenarioQuestUseItemVerifyPosSucc.dealUseItem(roleid, mission.getId(), itemid);
                        logger.info("角色[" + roleid + "]使用任务道具[" + itemid + "],无坐标配置需求,直接处理,结果:" + useSucc);
                        if (useSucc) {
                            return UseResult.SUCC;
                        }

                        return UseResult.FAIL;
                    }

                    GScenarioQuestUseItemVerifyPos send = new GScenarioQuestUseItemVerifyPos();
                    send.roleid = roleid;
                    send.scenarioquestid = mission.getId();
                    send.mapid = conf.exeIndo.mapID;
                    send.useitemid = itemid;
                    send.left = conf.exeIndo.leftPos;
                    send.right = conf.exeIndo.rightPos;
                    send.top = conf.exeIndo.topPos;
                    send.bottom = conf.exeIndo.bottomPos;
                    if (itemid > 50275 && itemid < 50286) {
                        ClanInfo clanInfo = ClanUtils.getClanInfoById(roleid, true);
                        if (clanInfo != null) {
                            StringBuffer message = new StringBuffer(256);
                            message.append("<T t=\"").append(clanInfo.getClanaim()).append("\" c=\"FFFFFFFF\"></T>");
                            MessageMgr.sendMsgToRoleAroundScreen(roleid, message.toString(), new ArrayList());
                        }
                    }

                    logger.info("角色[" + roleid + "]使用任务道具[" + itemid + "],有坐标配置需求,转到地图线程处理!");
                    GsClient.pSendWhileCommit(send);
                    return UseResult.AWAIT;
                }
            }
        }

        return UseResult.FAIL;
    }

    public ReloadResult reload() throws Exception {
        ConfigManager cm = ConfigManager.getInstance();
        MissionManager.getInstance().init(cm);
        return new ReloadResult(true);
    }

    private void sendAllAcceptedMission(long roleid) {
        this.sendMasterMission(roleid);
    }

    private void sendAllCanAcceptMission(long roleid) {
        SReqMissionCanAccept send = new SReqMissionCanAccept();
        this.getCanAcceptMission(roleid, send.missions);
        Procedure.psendWhileCommit(roleid, send);
    }

    private void sendMasterMission(long roleid) {
        (new PClearCircleTask(roleid, false, true)).call();
        CircleTaskManager.sendAllSpecialQuest(roleid);
    }

    private void sendScenarioMission(long roleid) {
        for(RoleMission sm : new MissionColumn(roleid, false)) {
            if (sm.getState() == 4 && UtilHelper.getMissionFinType(sm.conf.exeIndo.missionType) == 9) {
            }

            if (sm.getState() == 4 || sm.getState() == 3) {
                SAcceptMission send = sm.toProtocol();
                Transaction.tsend(roleid, send);
            }

            if (sm instanceof MissionMajorScenario && sm.getState() == 1) {
                Set<Integer> posts = MissionManager.getInstance().getPostmissions(UtilHelper.getMissionLineid(sm.getId()));
                if (posts != null) {
                    for(Integer nextmission : posts) {
                        if ((new PAcceptMajorMission(roleid, nextmission, true)).call()) {
                            break;
                        }
                    }
                }
            }
        }

    }

    private void sendTracked(long roleid) {
        STrackedMissions send = new STrackedMissions();
        TrackedMission tt = Trackedmission.select(roleid);
        if (tt != null) {
            for(Map.Entry<Integer, Track> e : tt.getQuestids().entrySet()) {
                fire.pb.mission.TrackedMission tq = new fire.pb.mission.TrackedMission();
                tq.acceptdate = ((Track)e.getValue()).getDate();
                send.trackedmissions.put(e.getKey(), tq);
            }

            Transaction.tsendWhileCommit(roleid, send);
        }
    }

    public void trackAccpetMission(final long roleid, final int questid) {
        final long accepttime = Calendar.getInstance().getTimeInMillis();
        Procedure p = new Procedure() {
            protected boolean process() {
                TrackedMission tt = Trackedmission.get(roleid);
                if (tt == null) {
                    tt = Pod.newTrackedMission();
                    Trackedmission.insert(roleid, tt);
                }

                Track xtrack = Pod.newTrack();
                xtrack.setDate(accepttime);
                tt.getQuestids().put(questid, xtrack);
                Module.logger.debug("角色[" + roleid + "]追踪任务[" + questid + "].");
                return true;
            }
        };
        if (Transaction.current() == null) {
            p.submit();
        } else {
            p.call();
        }

    }

    public void untrackMission(final long roleid, final int questid) {
        Procedure p = new Procedure() {
            protected boolean process() {
                TrackedMission tt = Trackedmission.get(roleid);
                if (tt == null) {
                    return false;
                } else {
                    tt.getQuestids().remove(questid);
                    Module.logger.debug("角色[" + roleid + "]取消追踪任务[" + questid + "].");
                    return true;
                }
            }
        };
        if (Transaction.current() == null) {
            p.submit();
        } else {
            p.call();
        }

    }
}
