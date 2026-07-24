//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.msp.npc.GCheckGathering;
import fire.pb.GsClient;
import fire.pb.PropRole;
import fire.pb.circletask.catchit.PSendCatchItNpcService;
import fire.pb.main.ConfigManager;
import fire.pb.map.Npc;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.mission.MissionColumn;
import fire.pb.mission.Module;
import fire.pb.mission.instance.InstanceManager;
import fire.pb.mission.instance.line.LineInstManager;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import gnet.link.Onlines;
import java.util.Collections;
import java.util.List;
import mkdb.Transaction;

public class CVisitNpc extends __CVisitNpc__ {
    public static final int PROTOCOL_TYPE = 795433;
    public long npckey;

    private boolean checkGatherTask(long roleid, SGatherConfig conf) {
        if (conf.tasks != null && !conf.tasks.isEmpty()) {
            return Module.getInstance().checkGather(roleid, conf);
        } else {
            fire.pb.npc.Module.logger.error("采集物的tasks字段为空");
            return true;
        }
    }

    private void gatherProcess(long roleid, int gatherid) {
        SGatherConfig conf = (SGatherConfig)ConfigManager.getInstance().getConf(SGatherConfig.class).get(gatherid);
        if (conf == null) {
            fire.pb.npc.Module.logger.error("没有该采集物的配置" + gatherid);
        } else if (this.checkGatherTask(roleid, conf)) {
            GCheckGathering send = new GCheckGathering();
            send.gatherkey = this.npckey;
            send.roleid = roleid;
            GsClient.sendToScene(send);
        }
    }

    public static void getScenarioQuests(long roleid, int npcid, SVisitNpc svisitNpc) {
        try {
            svisitNpc.scenarioquests.clear();
            svisitNpc.scenarioquests = (new MissionColumn(roleid, true)).getMissionsByNpcid(npcid, svisitNpc);
            Collections.sort(svisitNpc.scenarioquests);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void onVisitNpc(long roleid, SNpcShare share) {
        if (share.npctype == 16) {
            fire.pb.instancezone.Module.visitNpc(roleid, this.npckey, share);
        } else if (share.npctype == 17) {
            InstanceManager.visitNpc(roleid, this.npckey, share);
        } else if (share.npctype == 28) {
            if (Transaction.current() != null) {
                (new PSendCatchItNpcService(share.getId(), this.npckey, roleid)).call();
            } else {
                (new PSendCatchItNpcService(share.getId(), this.npckey, roleid)).submit();
            }

        } else if (LineInstManager.getInstance().checkLineNpc(share.getId())) {
            LineInstManager.visitNpc(roleid, this.npckey, share);
        } else if (!this.checkNpcVisitable(roleid)) {
            fire.pb.npc.Module.logger.info("npc is unvisitable");
        } else {
            SpecialNpcDialogProcessor processor = SpecialVisitProcessCreator.getInstance().createNpcDialogProcessor(roleid, this.npckey);
            if (null != processor) {
                fire.pb.npc.Module.logger.info("specialNpcDialog. npcid:" + share.id);
                processor.onVisitNpc();
            } else {
                SVisitNpc svisitNpc = new SVisitNpc();
                svisitNpc.npckey = this.npckey;
                List<Integer> services = NpcServiceManager.getInstance().getShowServicesIDSByNpcKey(roleid, this.npckey);
                if (null != services) {
                    svisitNpc.services.addAll(services);
                }

                getScenarioQuests(roleid, share.id, svisitNpc);
                Onlines.getInstance().send(roleid, svisitNpc);
                fire.pb.npc.Module.logger.info("SVisitNpc协议内容-" + this.getString(svisitNpc, share.id));
            }
        }
    }

    private String getString(SVisitNpc svisitNpc, int npcid) {
        StringBuffer sb = new StringBuffer();
        sb.append("NPC:[" + npcid + "],");
        sb.append("Services:[");

        for(Integer serviceid : svisitNpc.services) {
            sb.append(serviceid + ";");
        }

        sb.append("],");
        sb.append("ScenarioQuests:[");

        for(Integer serviceid : svisitNpc.scenarioquests) {
            sb.append(serviceid + ";");
        }

        sb.append("].");
        return sb.toString();
    }

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid < 0L) {
            fire.pb.npc.Module.logger.error("访问npc的角色 ： " + roleid + "有错");
        } else {
            PropRole prole = new PropRole(roleid, true);
            if (prole.getProperties().getCruise() > 0) {
                fire.pb.npc.Module.logger.error("访问npc的角色 ： " + roleid + "巡游状态，禁止访问.");
            } else {
                Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
                if (npc == null) {
                    fire.pb.npc.Module.logger.error("访问npc不存在 ： " + this.npckey);
                } else {
                    SNpcShare share = NpcManager.getInstance().getNpcShareByID(npc.getNpcID());
                    if (share == null) {
                        fire.pb.npc.Module.logger.error("访问npc的id ： " + npc.getNpcID() + "有错 share为null");
                    } else if (share.npctype == 5) {
                        Role role = RoleManager.getInstance().getRoleByID(roleid);
                        if (!role.checkDistance(npc, 400)) {
                            fire.pb.npc.Module.logger.error("访问npc的距离过远 ： " + npc.getNpcID());
                        } else {
                            this.gatherProcess(roleid, share.id);
                        }
                    } else if (!SceneNpcManager.checkDistance(this.npckey, roleid)) {
                        fire.pb.npc.Module.logger.error("npc的距离过远 ： " + npc.getNpcID());
                    } else {
                        Team team = TeamManager.selectTeamByRoleId(roleid);
                        if (team != null) {
                            if (team.isTeamLeader(roleid)) {
                                if (share.share == 1) {
                                    for(Long member : team.getNormalMemberIds()) {
                                        this.onVisitNpc(member, share);
                                    }
                                } else {
                                    this.onVisitNpc(roleid, share);
                                }
                            } else if (team.isAbsentMember(roleid)) {
                                this.onVisitNpc(roleid, share);
                            }
                        } else {
                            this.onVisitNpc(roleid, share);
                        }

                    }
                }
            }
        }
    }

    private boolean checkNpcVisitable(long roleid) {
        return true;
    }

    public int getType() {
        return 795433;
    }

    public CVisitNpc() {
    }

    public CVisitNpc(long _npckey_) {
        this.npckey = _npckey_;
    }

    public final boolean _validator_() {
        return this.npckey >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CVisitNpc) {
            CVisitNpc _o_ = (CVisitNpc)_o1_;
            return this.npckey == _o_.npckey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CVisitNpc _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.npckey - _o_.npckey);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
