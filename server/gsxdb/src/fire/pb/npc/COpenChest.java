//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.activity.award.RewardMgr;
import fire.pb.activity.clanfight.ActivityClanFightManager;
import fire.pb.activity.timernpc.TimerNpcService;
import fire.pb.clan.ClanUtils;
import fire.pb.clan.fight.ClanFightBattleField;
import fire.pb.clan.fight.ClanFightFactory;
import fire.pb.clan.fight.PClanFightOpenChest;
import fire.pb.instancezone.InstanceZone;
import fire.pb.instancezone.InstanceZoneFactory;
import fire.pb.instancezone.Module;
import fire.pb.instancezone.conf.InstanceZoneConfig;
import fire.pb.instancezone.faction.FactionInstZone;
import fire.pb.map.Npc;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.BaoXiangInfo;
import xbean.BestowNpcInfo;
import xbean.ClanInfo;
import xbean.EClanfightids;
import xbean.Pod;
import xbean.Properties;
import xbean.RoleBestowCount;
import xbean.RoleBestowInfo;
import xtable.Bestownpc;
import xtable.Clanid2clanfightids;
import xtable.Locks;
import xtable.Rolebestow;
import xtable.Roleid2clanfightid;
import xtable.Rolekaibaoxiang;

public class COpenChest extends __COpenChest__ {
    public static final int PROTOCOL_TYPE = 795522;
    public long chestnpckey;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId != -1L) {
            final Role role = RoleManager.getInstance().getRoleByID(roleId);
            if (null != role) {
                InstanceZone instzone = InstanceZoneFactory.getRoleCurInstanceZone(roleId, true);
                if (instzone != null) {
                    InstanceZoneConfig zoneconfig = (InstanceZoneConfig)Module.getInstance().getInstanceZoneConfigs().get(instzone.getInstZoneId());
                    if (zoneconfig != null) {
                        long now = System.currentTimeMillis();
                        if (zoneconfig.inEnterTime(now)) {
                            (new Procedure() {
                                protected boolean process() throws Exception {
                                    InstanceZone instzone = InstanceZoneFactory.getRoleCurInstanceZone(roleId, false);
                                    return instzone instanceof FactionInstZone ? ((FactionInstZone)instzone).openChest(roleId, COpenChest.this.chestnpckey) : false;
                                }
                            }).submit();
                            return;
                        }
                    }

                } else if (SceneNpcManager.checkDistance(this.chestnpckey, roleId)) {
                    (new Procedure() {
                        protected boolean process() throws Exception {
                            Npc npc = SceneNpcManager.getNpcByKey(COpenChest.this.chestnpckey);
                            if (npc == null) {
                                return false;
                            } else {
                                SBaoxiang chestcfg = ChestManager.getInstance().getChestConfig(npc.getNpcID());
                                if (chestcfg == null) {
                                    return false;
                                } else {
                                    Long clanfightid = Roleid2clanfightid.select(roleId);
                                    if (clanfightid != null && npc.getNpcID() == ActivityClanFightManager.VICTORY_BOX) {
                                        ClanFightBattleField bf = ClanFightFactory.getClanFightBattleField(clanfightid, true);
                                        if (bf != null) {
                                            if (!bf.getClanfightBean().getEnterroleids().containsKey(roleId)) {
                                                return false;
                                            }

                                            boolean ok = bf.IsWinnerSide(roleId, true);
                                            if (ok) {
                                                Procedure.pexecuteWhileCommit(new PClanFightOpenChest(clanfightid, roleId, COpenChest.this.chestnpckey));
                                                return true;
                                            }
                                        }

                                        return false;
                                    } else {
                                        Properties prop = xtable.Properties.select(roleId);
                                        if (prop == null) {
                                            return false;
                                        } else {
                                            int mapid = role.getMapId();
                                            if (mapid == ClanUtils.MAPID && npc.getNpcID() == ActivityClanFightManager.CELEBRATE_BOX) {
                                                ClanInfo clanInfo = ClanUtils.getClanInfoById(roleId, true);
                                                if (clanInfo == null) {
                                                    return false;
                                                } else {
                                                    long clanid = clanInfo.getKey();
                                                    EClanfightids ids = Clanid2clanfightids.select(clanid);

                                                    for(Long i : ids.getIds()) {
                                                        ClanFightBattleField bf = ClanFightFactory.getClanFightBattleField(i, true);
                                                        if (bf != null) {
                                                            long day1 = 86400000L;
                                                            long cur = System.currentTimeMillis();
                                                            long t = bf.getClanfightBean().getDatetime() + day1;
                                                            if (DateValidate.inTheSameDay(t, cur)) {
                                                                if (!bf.getClanfightBean().getEnterroleids().containsKey(roleId)) {
                                                                    MessageMgr.sendMsgNotify(roleId, 410050, (List)null);
                                                                    return false;
                                                                }

                                                                boolean ok = bf.IsWinnerSide(roleId, true);
                                                                if (ok) {
                                                                    Procedure.pexecuteWhileCommit(new PClanFightOpenChest(bf.getClanfightBean().getClanfightid(), roleId, COpenChest.this.chestnpckey));
                                                                    return true;
                                                                }

                                                                MessageMgr.sendMsgNotify(roleId, 410050, (List)null);
                                                                return false;
                                                            }
                                                        }
                                                    }

                                                    MessageMgr.sendMsgNotify(roleId, 410050, (List)null);
                                                    return false;
                                                }
                                            } else {
                                                int biaoId = TimerNpcService.getInstance().getEventId(npc.getNpcID());
                                                int opentimes = chestcfg.getOpentimes();
                                                long currentTime = System.currentTimeMillis();
                                                Team team = TeamManager.selectTeamByRoleId(roleId);
                                                if (null != team && team.isTeamLeader(roleId) && chestcfg.getOpenteam() == 1) {
                                                    List<Long> members = team.getNormalMemberIds();
                                                    this.lock(xtable.Locks.ROLELOCK, members);
                                                    BaoXiangInfo baoxiangInfo = Rolekaibaoxiang.select(roleId);
                                                    if (baoxiangInfo != null && DateValidate.inTheSameDay(baoxiangInfo.getLastopentime(), currentTime) && baoxiangInfo.getOpentimes() >= opentimes) {
                                                        MessageMgr.psendMsgNotifyWhileRollback(roleId, 166004, (List)null);
                                                        return false;
                                                    }

                                                    int rolelevel = xtable.Properties.selectLevel(roleId);
                                                    if (chestcfg.openlevel > rolelevel) {
                                                        MessageMgr.sendMsgNotify(roleId, 166139, (List)null);
                                                        return false;
                                                    }

                                                    for(Long rid : members) {
                                                        BaoXiangInfo memberBaoxiangInfo = Rolekaibaoxiang.get(rid);
                                                        if (memberBaoxiangInfo == null) {
                                                            memberBaoxiangInfo = Pod.newBaoXiangInfo();
                                                            Rolekaibaoxiang.insert(rid, memberBaoxiangInfo);
                                                        }

                                                        if (!DateValidate.inTheSameDay(memberBaoxiangInfo.getLastopentime(), currentTime)) {
                                                            memberBaoxiangInfo.setOpentimes(0);
                                                        }

                                                        if (memberBaoxiangInfo.getOpentimes() >= opentimes) {
                                                            MessageMgr.psendMsgNotify(rid, 166003, (List)null);
                                                        } else {
                                                            RewardMgr.getInstance().distributeAllAward(rid, chestcfg.rewardid, (Map)null, YYLoggerTuJingEnum.tujing_Value_baoxiang, 0, 4002, "开启宝箱");
                                                            memberBaoxiangInfo.setOpentimes(memberBaoxiangInfo.getOpentimes() + 1);
                                                            memberBaoxiangInfo.setLastopentime(currentTime);
                                                        }
                                                    }
                                                } else {
                                                    int rolelevel = xtable.Properties.selectLevel(roleId);
                                                    if (chestcfg.openlevel > rolelevel) {
                                                        MessageMgr.sendMsgNotify(roleId, 166139, (List)null);
                                                        return false;
                                                    }

                                                    if (npc.getNpcID() == 300002) {
                                                        BestowNpcInfo npcInfo = Bestownpc.get(COpenChest.this.chestnpckey);
                                                        if (npcInfo == null) {
                                                            return false;
                                                        }

                                                        RoleBestowInfo bestowInfo = Rolebestow.get(roleId);
                                                        if (bestowInfo == null) {
                                                            bestowInfo = Pod.newRoleBestowInfo();
                                                            Rolebestow.insert(roleId, bestowInfo);
                                                        }

                                                        long npcRoleId = npcInfo.getRoleid();
                                                        RoleBestowCount bestowCount = (RoleBestowCount)bestowInfo.getRolebestowinfo().get(npcInfo.getRoleid());
                                                        if (bestowCount == null) {
                                                            bestowCount = Pod.newRoleBestowCount();
                                                            bestowInfo.getRolebestowinfo().put(npcRoleId, bestowCount);
                                                        }

                                                        if (bestowCount.getOpentimes() >= opentimes) {
                                                            MessageMgr.psendMsgNotifyWhileRollback(roleId, chestcfg.getOpenovermsg(), (List)null);
                                                            return false;
                                                        }

                                                        RewardMgr.getInstance().distributeAllAward(roleId, chestcfg.rewardid, (Map)null, YYLoggerTuJingEnum.tujing_Value_baoxiang, 0, 4002, "开启宝箱");
                                                        bestowCount.setOpentimes(bestowCount.getOpentimes() + 1);
                                                    } else {
                                                        BaoXiangInfo baoxiangInfo = Rolekaibaoxiang.get(roleId);
                                                        if (baoxiangInfo == null) {
                                                            baoxiangInfo = Pod.newBaoXiangInfo();
                                                            Rolekaibaoxiang.insert(roleId, baoxiangInfo);
                                                        }

                                                        if (!DateValidate.inTheSameDay(baoxiangInfo.getLastopentime(), currentTime)) {
                                                            baoxiangInfo.setOpentimes(0);
                                                        }

                                                        if (baoxiangInfo.getOpentimes() >= opentimes) {
                                                            MessageMgr.psendMsgNotifyWhileRollback(roleId, chestcfg.getOpenovermsg(), (List)null);
                                                            return false;
                                                        }

                                                        RewardMgr.getInstance().distributeAllAward(roleId, chestcfg.rewardid, (Map)null, YYLoggerTuJingEnum.tujing_Value_baoxiang, 0, 4002, "开启宝箱");
                                                        baoxiangInfo.setOpentimes(baoxiangInfo.getOpentimes() + 1);
                                                        baoxiangInfo.setLastopentime(currentTime);
                                                    }
                                                }

                                                TimerNpcService.getInstance().removeEventNpc(biaoId, COpenChest.this.chestnpckey);
                                                return true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }).submit();
                }
            }
        }
    }

    public int getType() {
        return 795522;
    }

    public COpenChest() {
    }

    public COpenChest(long _chestnpckey_) {
        this.chestnpckey = _chestnpckey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.chestnpckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.chestnpckey = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof COpenChest) {
            COpenChest _o_ = (COpenChest)_o1_;
            return this.chestnpckey == _o_.chestnpckey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.chestnpckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.chestnpckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(COpenChest _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.chestnpckey - _o_.chestnpckey);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
