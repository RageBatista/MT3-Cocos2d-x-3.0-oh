//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import fire.pb.activity.impexam.PApplyImpExamProc;
import fire.pb.activity.timernpc.PFightProc;
import fire.pb.activity.timernpc.PTimerNpcFightProc;
import fire.pb.activity.winner.CReqStartWinner;
import fire.pb.activity.winner.CStartWinnerBattle;
import fire.pb.battle.pvp.IPvPServiceHandle;
import fire.pb.battle.pvp.PvPServiceHandleFactory;
import fire.pb.circletask.CircleTask;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.circletask.PAcceptCircTask;
import fire.pb.circletask.PSendMail2Dst;
import fire.pb.circletask.PSubmitCircleTask;
import fire.pb.circletask.SRenXingCircleTask;
import fire.pb.circletask.catchit.EnterCatchItBattle;
import fire.pb.circletask.catchit.PQueryCatchItTaskTime;
import fire.pb.clan.fight.PEnterClanFightBattleField;
import fire.pb.effect.Module;
import fire.pb.instancezone.PEndNpcBattle;
import fire.pb.instancezone.PInstNpcService;
import fire.pb.instancezone.PWatchNpcBattle;
import fire.pb.instancezone.bingfeng.BingFengLandMgr;
import fire.pb.instancezone.bingfeng.BingFengWangZuoConfig;
import fire.pb.instancezone.bingfeng.PBattletoBingFeng;
import fire.pb.instancezone.conf.InstanceZoneConfig;
import fire.pb.item.PProduceItem;
import fire.pb.item.Pack;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import fire.pb.master.MasterManager;
import fire.pb.mission.ExecuteReqGoto;
import fire.pb.mission.PAcceptMajorMission;
import fire.pb.mission.instance.InstanceManager;
import fire.pb.mission.instance.PBackInstanceScenceProc;
import fire.pb.mission.instance.PGiveInstanceProc;
import fire.pb.mission.instance.line.LineInstManager;
import fire.pb.mission.instance.line.PGiveLineProc;
import fire.pb.mission.instance.line.PQueryLineTime;
import fire.pb.mission.instance.line.PSendResetLineTask;
import fire.pb.mission.treasuremap.PEventNpcFightProc;
import fire.pb.ranklist.SRequestRankList;
import fire.pb.ranklist.proc.RankListManager;
import fire.pb.scene.manager.RoleManager;
import fire.pb.scene.movable.Role;
import fire.pb.school.shouxi.CChallengeShouXiDiZi;
import fire.pb.school.shouxi.CCheckCanElect;
import fire.pb.school.shouxi.CReqCandidatesList;
import fire.pb.school.shouxi.PMyElector;
import fire.pb.school.shouxi.PSendCandidateList;
import fire.pb.talk.MessageMgr;
import fire.pb.weibo.PTakeWeiBoAwardProc;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;

public class CNpcService extends __CNpcService__ {
    public static final int PROTOCOL_TYPE = 795435;
    public long npckey;
    public int serviceid;

    boolean dealNpcServiceMapping(long roleid, int serviceid) {
        try {
            SNpcServiceMapping conf = NpcServiceManager.getInstance().getServiceMappingByServiceID(serviceid);
            if (null == conf) {
                return false;
            } else {
                int curType = conf.getType();
                switch (curType) {
                    case 1: {
                        int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                        (new PAcceptCircTask(roleid, this.npckey, npcid, conf.getParam1(), true)).submit();
                        return true;
                    }
                    case 2: {
                        (new PSubmitCircleTask(conf.getParam1(), roleid, this.npckey, new ArrayList())).submit();
                        return true;
                    }
                    case 3: {
                        int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                        (new PQueryCatchItTaskTime(roleid, npcid, conf.getParam1())).submit();
                        return true;
                    }
                    case 5: {
                        int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                        EnterCatchItBattle enter = new EnterCatchItBattle(roleid, this.npckey, npcid, conf.getParam1());
                        enter.enterBattle();
                        return true;
                    }
                    case 6: {
                        int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                        (new PProduceItem(roleid, conf.getParam1(), npcid, conf.getParam2())).submit();
                        return true;
                    }
                    case 7: {
                        CircleTask sq = new CircleTask(roleid, true);
                        int renxingtimes = sq.getRenXingCircTaskCount(roleid, conf.getParam1());
                        Onlines.getInstance().send(roleid, new SRenXingCircleTask(serviceid, conf.getParam1(), renxingtimes, this.npckey));
                        return true;
                    }
                    case 9: {
                        int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                        CircleTask sq = new CircleTask(roleid, true);
                        boolean ret = sq.exeCircTaskBattle(roleid, this.npckey, conf.getParam1(), npcid);
                        Module.logger.debug("玩家[" + roleid + "]" + "exeCircTaskBattle结果:" + ret);
                        return true;
                    }
                    case 10: {
                        Integer instid = conf.getParam1();
                        InstanceZoneConfig zoneconfig = (InstanceZoneConfig)fire.pb.instancezone.Module.getInstance().getInstanceZoneConfigs().get(instid);
                        if (zoneconfig == null) {
                            return false;
                        }

                        (new PInstNpcService(instid, serviceid, roleid)).submit();
                        return true;
                    }
                    case 13: {
                        (new PAcceptMajorMission(roleid, conf.getParam1(), true, true)).call();
                        return true;
                    }
                    case 0:
                    case 4:
                    case 8:
                    case 11:
                    case 12:
                    default:
                        return false;
                }
            }
        } catch (Exception var9) {
            Module.logger.error("玩家[" + roleid + "]" + "serviceid:" + serviceid + "处理异常");
            return false;
        }
    }

    public void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (StateCommon.isOnline(roleid)) {
                if (100002 == this.serviceid || !fire.pb.buff.Module.existState(roleid, 507004)) {
                    if (PNpcAwardProc.containedByNpcAward(this.serviceid)) {
                        (new PNpcAwardProc(roleid, this.serviceid)).submit();
                    } else {
                        int npcId = NpcServiceManager.getNpcIDByKey(this.npckey);
                        Pack bag = new Pack(roleid, true);
                        long v = bag.getCurrency(4);
                        if (this.serviceid == 900054) {
                            if (v >= 60L) {
                                (new PAcceptCircTask(roleid, this.npckey, npcId, 1120000, true)).submit();
                            } else {
                                ArrayList<String> s = new ArrayList();
                                s.add("60");
                                MessageMgr.sendMsgNotify(roleid, 190070, s);
                            }

                        } else if (this.serviceid == 900055) {
                            if (v >= 120L) {
                                (new PAcceptCircTask(roleid, this.npckey, npcId, 1130000, true)).submit();
                            } else {
                                ArrayList<String> s = new ArrayList();
                                s.add("120");
                                MessageMgr.sendMsgNotify(roleid, 190070, s);
                            }

                        } else if (this.serviceid == 900056) {
                            if (v >= 180L) {
                                (new PAcceptCircTask(roleid, this.npckey, npcId, 1140000, true)).submit();
                            } else {
                                ArrayList<String> s = new ArrayList();
                                s.add("180");
                                MessageMgr.sendMsgNotify(roleid, 190070, s);
                            }

                        } else if (this.dealNpcServiceMapping(roleid, this.serviceid)) {
                            Module.logger.info("NPC服务映射处理了角色[" + roleid + "]的服务[" + this.serviceid + "].");
                        } else if (CircleTaskManager.getInstance().isSendMailService(this.serviceid)) {
                            Module.logger.info("角色[" + roleid + "]的服务[" + this.serviceid + "]触发循环任务邮件发送.");
                            int npcid = NpcServiceManager.getNpcIDByKey(this.npckey);
                            (new PSendMail2Dst(roleid, npcid, this.serviceid)).submit();
                        } else if (this.serviceid == 910030) {
                            (new PEnterClanFightBattleField(roleid)).submit();
                        } else if (!SceneNpcManager.checkDistance(this.npckey, roleid)) {
                            MessageMgr.sendMsgNotify(roleid, 142369, (List)null);
                        } else {
                            SNpcShare share = NpcManager.getInstance().getNpcShareByID(npcId);
                            if (share == null) {
                                Module.logger.error("SNpcShare == null,npcId = " + npcId + ",serviceid = " + this.serviceid + ",roleid = " + roleid);
                            } else if (share.npctype == 16) {
                                if (this.serviceid == 910201) {
                                    (new PWatchNpcBattle(roleid, this.npckey)).submit();
                                } else if (this.serviceid == 910202) {
                                    (new PEndNpcBattle(roleid, this.npckey)).submit();
                                } else {
                                    fire.pb.instancezone.Module.doNpcService(roleid, this.npckey, share, this.serviceid);
                                }
                            } else if (NpcServiceManager.getInstance().hasServiceByNpcKey(roleid, this.npckey, new int[]{this.serviceid})) {
                                Npc gsnpc = SceneNpcManager.selectNpcByKey(this.npckey);
                                if (gsnpc != null) {
                                    if (this.serviceid != 69 && this.serviceid != 3000 && this.serviceid != 3001 && this.serviceid != 3002 && this.serviceid != 3003 && this.serviceid != 3004 && this.serviceid != 3005 && this.serviceid != 3010 && this.serviceid != 3011 && this.serviceid != 3012 && this.serviceid != 3013 && this.serviceid != 3014 && this.serviceid != 3015 && this.serviceid != 4000 && this.serviceid != 4001 && this.serviceid != 4004 && this.serviceid != 4002) {
                                        if (this.serviceid == 4005) {
                                            (new PTimerNpcFightProc(roleid, npcId, this.npckey)).submit();
                                        } else if (this.serviceid == 4006) {
                                            (new PEventNpcFightProc(roleid, npcId, this.npckey)).submit();
                                        } else if (this.serviceid == 910115) {
                                            (new fire.pb.activity.timernpc.PWatchNpcBattle(roleid, npcId, this.npckey)).submit();
                                        } else if (this.serviceid == 910116) {
                                            (new fire.pb.mission.treasuremap.PWatchNpcBattle(roleid, npcId, this.npckey)).submit();
                                        } else if (this.serviceid == 999999) {
                                            (new PFightProc(roleid, npcId, this.npckey)).submit();
                                        } else if (this.serviceid == 999998) {
                                            Role role = RoleManager.getInstance().getRoleByProtocol(this);
                                            if (null != role) {
                                                (new PJieHun(roleid, role, 1)).submit();
                                                System.out.println("-------申请结婚-------");
                                            }
                                        } else if (this.serviceid == 999997) {
                                            Role role = RoleManager.getInstance().getRoleByProtocol(this);
                                            if (null != role) {
                                                (new PJieHun(roleid, role, 2)).submit();
                                                System.out.println("-------协议离婚-------");
                                            }
                                        } else if (this.serviceid == 999996) {
                                            Role role = RoleManager.getInstance().getRoleByProtocol(this);
                                            if (null != role) {
                                                (new PJieHun(roleid, role, 3)).submit();
                                                System.out.println("-------强制离婚-------");
                                            }
                                        } else if (this.serviceid == 14) {
                                            PReqFortuneWheel pwheel = new PReqFortuneWheel(roleid, this.npckey, npcId, true, 14);
                                            pwheel.submit();
                                        } else if (this.serviceid == 900057) {
                                            (new PSendCandidateList(roleid, this.npckey)).submit();
                                        } else if (this.serviceid == 99) {
                                            (new CReqCandidatesList(roleid, this.npckey)).process();
                                        } else if (this.serviceid == 900060) {
                                            (new CCheckCanElect(roleid, this.npckey)).process();
                                        } else if (this.serviceid == 900059) {
                                            (new CChallengeShouXiDiZi(roleid, this.npckey)).process();
                                        } else if (this.serviceid == 900058) {
                                            (new PMyElector(roleid, this.npckey)).submit();
                                        } else if (this.serviceid == 166) {
                                            (new CReqStartWinner(roleid, this.npckey)).process();
                                        } else if (this.serviceid == 171) {
                                            (new CStartWinnerBattle(roleid, this.npckey)).process();
                                        } else if (InstanceManager.getInstance().getInstNpcServers().contains(this.serviceid)) {
                                            (new PGiveInstanceProc(roleid, this.npckey, this.serviceid)).submit();
                                        } else if (LineInstManager.getInstance().getInstNpcServers().contains(this.serviceid)) {
                                            (new PGiveLineProc(roleid, this.npckey, this.serviceid)).submit();
                                        } else if (this.serviceid == 1469) {
                                            (new PBackInstanceScenceProc(roleid)).submit();
                                        } else if (this.serviceid == 1923) {
                                            ExecuteReqGoto.trans2Pos(roleid, 1014, 39, 27, false);
                                        } else if (this.serviceid == 1924) {
                                            ExecuteReqGoto.trans2Pos(roleid, 1004, 27, 89, false);
                                        } else if (this.serviceid == 1925) {
                                            ExecuteReqGoto.trans2Pos(roleid, 1008, 89, 38, false);
                                        } else if (this.serviceid == 355) {
                                            BingFengWangZuoConfig bfconfig = BingFengLandMgr.getInstance().getBingFengConfigByRoleLv(roleid);
                                            if (bfconfig != null) {
                                                int rankid = BingFengLandMgr.getInstance().getRankIdByInstzoneId(bfconfig.getInstzoneid());
                                                SRequestRankList requestRankList = RankListManager.getInstance().getRankListResponse(rankid, roleid, 0);
                                                Onlines.getInstance().send(roleid, requestRankList);
                                                BingFengLandMgr.sendSBingFengInfo(roleid, rankid);
                                            } else {
                                                int rankid = BingFengLandMgr.getInstance().getRankIdByInstzoneId(1);
                                                SRequestRankList requestRankList = RankListManager.getInstance().getRankListResponse(rankid, roleid, 0);
                                                Onlines.getInstance().send(roleid, requestRankList);
                                                BingFengLandMgr.sendSBingFengInfo(roleid, rankid);
                                            }

                                        } else if (this.serviceid != 1078 && this.serviceid != 1079) {
                                            if (this.serviceid == 1987) {
                                                (new PTakeWeiBoAwardProc(roleid)).submit();
                                            } else {
                                                IPvPServiceHandle sHandle = PvPServiceHandleFactory.create(this.serviceid);
                                                if (sHandle != null) {
                                                    sHandle.handle(roleid, this.serviceid);
                                                } else if (BingFengLandMgr.bingFengServiceids.contains(this.serviceid)) {
                                                    (new PBattletoBingFeng(roleid, npcId)).submit();
                                                } else if (this.serviceid == 1801) {
                                                    InstanceManager.getInstance().abandonInstanceTask(roleid);
                                                } else if (!MasterManager.masterService(roleid, this.serviceid)) {
                                                    if (this.serviceid == 100704) {
                                                        (new PApplyImpExamProc(roleid, 3, 1)).submit();
                                                    } else if (this.serviceid == 100187) {
                                                        (new PSendResetLineTask(roleid)).submit();
                                                    } else if (this.serviceid == 100049) {
                                                        (new PQueryLineTime(roleid)).submit();
                                                    } else {
                                                        if (this.serviceid == 200101) {
                                                            (new PLookYaoQian(roleid, this.npckey)).submit();
                                                        }

                                                    }
                                                }
                                            }
                                        } else {
                                            (new PReceiveAccountInfoAward(roleid, this.serviceid)).submit();
                                        }
                                    } else {
                                        CircleTaskManager.getInstance().process(roleid, this.npckey, this.serviceid);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public int getType() {
        return 795435;
    }

    public CNpcService() {
    }

    public CNpcService(long _npckey_, int _serviceid_) {
        this.npckey = _npckey_;
        this.serviceid = _serviceid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.serviceid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.serviceid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CNpcService) {
            CNpcService _o_ = (CNpcService)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else {
                return this.serviceid == _o_.serviceid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.serviceid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.serviceid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CNpcService _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.serviceid - _o_.serviceid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
