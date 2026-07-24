//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.Logger;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.circletask.PSubmitItemPetQuest;
import fire.pb.instancezone.PSubmit2Npc;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import fire.pb.mission.MissionColumn;
import fire.pb.mission.PCommitMajorMission;
import fire.pb.mission.UtilHelper;
import fire.pb.mission.util.MoneyCommitParam;
import fire.pb.mission.util.PetCommitParam;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetInfo;

public class CSubmit2Npc extends __CSubmit2Npc__ {
    static Logger logger = Logger.getLogger("MAPMAIN");
    public static final int PROTOCOL_TYPE = 795456;
    public int questid;
    public long npckey;
    public int submittype;
    public ArrayList<SubmitUnit> things;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (!SceneNpcManager.checkDistance(this.npckey, roleid)) {
                if (this.submittype == 22) {
                    STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(160176, 0, (List)null);
                    Onlines.getInstance().send(roleid, msg);
                }

            } else {
                Npc npc = SceneNpcManager.selectNpcByKey(this.npckey);
                int npcid = 0;
                if (npc != null) {
                    npcid = npc.getNpcID();
                }

                Pack submiterBag = new Pack(roleid, true);

                for(SubmitUnit unit : this.things) {
                    if (this.submittype != 2) {
                        if (this.submittype == 3) {
                            long money = (long)unit.key;
                            if (submiterBag.getMoney() < money) {
                                logger.error("submit money error.roleid:" + roleid + "unit.key:" + unit.key + "unit.num:" + unit.num + "money:" + money + "npcid:" + npcid);
                            }
                        } else {
                            ItemBase bi = submiterBag.getItem(unit.key);
                            if (bi == null) {
                                logger.error("submit item is empty.roleid:" + roleid + "unit.key:" + unit.key + "unit.num:" + unit.num + "npcid:" + npcid);
                            } else if (bi.getNumber() < unit.num) {
                                logger.error("submit item num error.roleid:" + roleid + "unit.key" + unit.key + "unit.num:" + unit.num + "realnum:" + bi.getNumber() + "npcid:" + npcid);
                            }
                        }
                    }
                }

                List<PetInfo> pis = null;
                if (this.submittype == 2) {
                    pis = new ArrayList();
                    PetColumn petcol = new PetColumn(roleid, 1, true);

                    for(SubmitUnit unit : this.things) {
                        Pet pet = petcol.getPet(unit.key);
                        if (pet == null || pet.isLocked() != -1L) {
                            return;
                        }

                        if (petcol.petIsFightPet(unit.key) || petcol.petIsShowPet(unit.key)) {
                            MessageMgr.sendMsgNotify(roleid, 144418, (List)null);
                            return;
                        }

                        pis.add(pet.getPetInfo().copy());
                    }
                }

                if (this.submittype == 1) {
                    Pack bag = new Pack(roleid, true);

                    for(SubmitUnit unit : this.things) {
                        ItemBase item = bag.getItem(unit.key);
                        if (item == null) {
                            return;
                        }
                    }
                }

                if (this.submittype == 13) {
                    (new PSubmit2Npc(roleid, this)).submit();
                }

                if (this.submittype == 22) {
                    (new PSubmit2Npc(roleid, this)).submit();
                }

                if (!UtilHelper.isMajorScenarioMission(this.questid) && !UtilHelper.isBranchScenarioMission(this.questid)) {
                    if (CircleTaskManager.getInstance().getCircTaskTypes().contains(new Integer(this.questid))) {
                        PSubmitItemPetQuest proc = new PSubmitItemPetQuest(roleid, this.questid, this.npckey, this.things);
                        Procedure.execute(proc, new DoneWhileSubmitPet(roleid, this.questid, pis));
                    }
                } else {
                    if (this.submittype == 1) {
                        Map<Integer, Integer> items = new HashMap();

                        for(SubmitUnit su : this.things) {
                            Integer num = (Integer)items.get(su.key);
                            if (num == null) {
                                items.put(su.key, su.num);
                            } else {
                                items.put(su.key, su.num + num);
                            }
                        }
                    } else if (this.submittype == 2) {
                        if (this.things.size() != 1) {
                            return;
                        }

                        SubmitUnit su = (SubmitUnit)this.things.get(0);
                        int petkey = su.key;
                        Team team = TeamManager.selectTeamByRoleId(roleid);
                        if (team != null && !team.isAbsentMember(roleid)) {
                            if (team.isTeamLeader(roleid)) {
                                int teamshare = (new MissionColumn(roleid, true)).getMission(this.questid).getConf().exeIndo.share;
                                if (teamshare == 0) {
                                    Procedure.execute(new PCommitMajorMission(roleid, this.questid, new PetCommitParam(this.npckey, petkey), true), new DoneWhileSubmitPet(roleid, this.questid, pis));
                                } else {
                                    for(long memid : team.getNormalMemberIds()) {
                                        if (memid == roleid) {
                                            Procedure.execute(new PCommitMajorMission(memid, this.questid, new PetCommitParam(this.npckey, petkey), true), new DoneWhileSubmitPet(memid, this.questid, pis));
                                        } else {
                                            Procedure.execute(new PCommitMajorMission(memid, this.questid, new PetCommitParam(this.npckey, petkey), false), new DoneWhileSubmitPet(memid, this.questid, pis));
                                        }
                                    }
                                }
                            }
                        } else {
                            Procedure.execute(new PCommitMajorMission(roleid, this.questid, new PetCommitParam(this.npckey, petkey), true), new DoneWhileSubmitPet(roleid, this.questid, pis));
                        }
                    } else if (this.submittype == 3) {
                        if (this.things.size() != 1) {
                            return;
                        }

                        SubmitUnit su = (SubmitUnit)this.things.get(0);
                        long money = (long)su.key;
                        Team team = TeamManager.selectTeamByRoleId(roleid);
                        if (team != null && !team.isAbsentMember(roleid)) {
                            if (team.isTeamLeader(roleid)) {
                                for(long memid : team.getNormalMemberIds()) {
                                    if (memid == roleid) {
                                        (new PCommitMajorMission(memid, this.questid, new MoneyCommitParam(this.npckey, money), true)).submit();
                                    } else {
                                        (new PCommitMajorMission(memid, this.questid, new MoneyCommitParam(this.npckey, money), false)).submit();
                                    }
                                }
                            }
                        } else {
                            (new PCommitMajorMission(roleid, this.questid, new MoneyCommitParam(this.npckey, money), true)).submit();
                        }
                    }

                }
            }
        }
    }

    public int getType() {
        return 795456;
    }

    public CSubmit2Npc() {
        this.things = new ArrayList();
    }

    public CSubmit2Npc(int _questid_, long _npckey_, int _submittype_, ArrayList<SubmitUnit> _things_) {
        this.questid = _questid_;
        this.npckey = _npckey_;
        this.submittype = _submittype_;
        this.things = _things_;
    }

    public final boolean _validator_() {
        if (this.questid < 0) {
            return false;
        } else if (this.npckey < 0L) {
            return false;
        } else if (this.submittype < 0) {
            return false;
        } else {
            for(SubmitUnit _v_ : this.things) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questid);
            _os_.marshal(this.npckey);
            _os_.marshal(this.submittype);
            _os_.compact_uint32(this.things.size());

            for(SubmitUnit _v_ : this.things) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questid = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.submittype = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            SubmitUnit _v_ = new SubmitUnit();
            _v_.unmarshal(_os_);
            this.things.add(_v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSubmit2Npc) {
            CSubmit2Npc _o_ = (CSubmit2Npc)_o1_;
            if (this.questid != _o_.questid) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.submittype != _o_.submittype) {
                return false;
            } else {
                return this.things.equals(_o_.things);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questid;
        _h_ += (int)this.npckey;
        _h_ += this.submittype;
        _h_ += this.things.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.submittype).append(",");
        _sb_.append(this.things).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
