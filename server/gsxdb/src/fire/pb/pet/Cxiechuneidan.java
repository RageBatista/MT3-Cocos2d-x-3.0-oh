//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffPetImpl;
import fire.pb.course.CourseManager;
import fire.pb.item.Pack;
import fire.pb.item.PetItemShuXing;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Module;
import fire.pb.skill.Result;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.BattleInfo;
import xbean.PetInfo;
import xbean.Properties;

public class Cxiechuneidan extends __Cxiechuneidan__ {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    public static final int PROTOCOL_TYPE = 817976;
    public int huanhuaid;
    public int petkey;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    Properties prop = xtable.Properties.get(roleid);
                    if (prop == null) {
                        return false;
                    } else {
                        Map<Integer, PetAttr> PetAttr = ConfigManager.getInstance().getConf(PetAttr.class);
                        if (PetAttr == null) {
                            return false;
                        } else {
                            PetColumn petColumn = new PetColumn(roleid, 1, false);
                            Pet pet = petColumn.getPet(Cxiechuneidan.this.petkey);
                            if (pet == null) {
                                return false;
                            } else {
                                PetInfo petInfo = petColumn.getPetInfo(Cxiechuneidan.this.petkey);
                                if (petInfo == null) {
                                    return false;
                                } else {
                                    Pack bag = new Pack(roleid, false);
                                    int confWeaponChangeCostGold = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(605).getValue());
                                    long ret = bag.subGold((long)(-confWeaponChangeCostGold), "转职转武器消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                                    if (ret != (long)(-confWeaponChangeCostGold)) {
                                        return false;
                                    } else {
                                        Map<Integer, PetItemShuXing> petItem = ConfigManager.getInstance().getConf(PetItemShuXing.class);

                                        for(PetItemShuXing pc : petItem.values()) {
                                            if (Cxiechuneidan.this.huanhuaid == pc.getSkillid()) {
                                                bag.addItem(pc.getId(), 1, "开套装", YYLoggerTuJingEnum.GM, 0, true);
                                                pet.removeInternalById(Cxiechuneidan.this.huanhuaid);
                                            }
                                        }

                                        BuffAgent buffAgent = new BuffPetImpl(roleid, Cxiechuneidan.this.petkey);
                                        if (Cxiechuneidan.this.huanhuaid > 0) {
                                            FightSkillConfig sconf = Module.getInstance().getFightSkillConfig(Cxiechuneidan.this.huanhuaid);
                                            if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                                SubSkillConfig[] arrayOfSubSkillConfig;
                                                for(SubSkillConfig subSkill : arrayOfSubSkillConfig = sconf.getSubSkills()) {
                                                    BuffUnit[] arrayOfBuffUnit;
                                                    for(BuffUnit buffArg : arrayOfBuffUnit = subSkill.getBuffUnits()) {
                                                        if (buffArg != null && buffArg.buffIndex > 0) {
                                                            buffAgent.removeCBuffWithSP(buffArg.buffIndex);
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        SkillPet spet = new SkillPet(petInfo, roleid);
                                        Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                                        buffAgent.psendSBuffChangeResult(result);
                                        spet.updateSkillBuffWhileOut((BattleInfo)null);
                                        pet.updatePetScoreWhileChange();
                                        CourseManager.checkAchieveCourse(roleid, 31, pet.getPetInfo().getPetscore());
                                        SRefreshPetInternal send = new SRefreshPetInternal();
                                        send.petkey = Cxiechuneidan.this.petkey;
                                        pet.fillSRefreshPetInternal(send);
                                        Procedure.psendWhileCommit(roleid, send);
                                        MessageMgr.sendMsgNotify(roleid, 192296, (List)null);
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

    public int getType() {
        return 817976;
    }

    public Cxiechuneidan() {
    }

    public Cxiechuneidan(int _huanhuaid_, int _petkey_) {
        this.huanhuaid = _huanhuaid_;
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.huanhuaid);
            _os_.marshal(this.petkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.huanhuaid = _os_.unmarshal_int();
        this.petkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Cxiechuneidan) {
            Cxiechuneidan _o_ = (Cxiechuneidan)_o1_;
            if (this.huanhuaid != _o_.huanhuaid) {
                return false;
            } else {
                return this.petkey == _o_.petkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.huanhuaid;
        _h_ += this.petkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.huanhuaid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Cxiechuneidan _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.huanhuaid - _o_.huanhuaid;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.petkey - _o_.petkey;
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}
