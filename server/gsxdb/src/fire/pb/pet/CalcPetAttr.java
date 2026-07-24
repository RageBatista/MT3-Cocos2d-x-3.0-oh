//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import fire.pb.effect.SPetAbilityScore;
import fire.pb.map.SceneManager;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import fire.pb.util.Misc;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Mkdb;
import xbean.PetInfo;
import xtable.Properties;

public class CalcPetAttr {
    private final PetAttr petAttr;
    private final PetInfo petInfo;
    public static int PET_NAME = 3;
    public static int PET_GROW_RATE_ID = 4;

    public CalcPetAttr(PetInfo petInfo) {
        this.petInfo = petInfo;
        if (null == petInfo) {
            Module.logger.warn("[CalcPetAttr] 构造函数 petInfo == null");
            throw new IllegalArgumentException("参数错误,不能使用此类进行计算, petInfo == null");
        } else {
            this.petAttr = Module.getInstance().getPetManager().getAttr(petInfo.getId());
            if (null == this.petAttr) {
                Module.logger.warn("[CalcPetAttr] 构造函数  宠物数据表找不到宠物ID " + petInfo.getId());
                throw new IllegalArgumentException("参数错误,不该使用此类进行计算, petAttr == null");
            }
        }
    }

    public PetAttr getPetAttr() {
        return this.petAttr;
    }

    public void setPetAttrByInitAttrs(Map<Integer, Object> initAttrs, int id) {
        this.initGrowRate();
        this.petInfo.setLife(this.getLifeFromConfig());
        if (initAttrs != null && initAttrs.containsKey(PET_NAME)) {
            this.petInfo.setName((String)initAttrs.get(PET_NAME));
        } else {
            this.petInfo.setName(this.getPetNameFromConfig());
        }

        PetAttr petAttr = Module.getInstance().getPetManager().getAttr(id);
        if (petAttr != null) {
            this.petInfo.setUselevel(petAttr.uselevel);
        }
    }

    public String getPetNameFromConfig() {
        return null == this.petAttr ? null : this.petAttr.name;
    }

    public void setInitAttrPoint() {
        if (null != this.petInfo && this.petAttr != null) {
            int[] point = new int[5];
            if (this.petAttr.getInitPointAssignType() == 1) {
                int n = this.petAttr.getInitPoint() / 5;
                int s = this.petAttr.getInitPoint() - n * 5;

                for(int i = 0; i < point.length; ++i) {
                    point[i] = n;
                }

                point[3] += s;
            } else if (this.petAttr.getInitPoint() >= 50) {
                Misc.RandomDistribute(this.petAttr.getInitPoint() - 50, 5, point);

                for(int i = 0; i < point.length; ++i) {
                    point[i] += 10;
                }
            } else {
                for(int i = 0; i < point.length; ++i) {
                    point[i] = 0;
                }

                if (this.petAttr.getInitPoint() > 0) {
                    Misc.RandomDistribute(this.petAttr.getInitPoint(), 5, point);
                }
            }

            this.petInfo.getBfp().setCons(point[0]);
            this.petInfo.getBfp().setIq(point[1]);
            this.petInfo.getBfp().setStr(point[2]);
            this.petInfo.getBfp().setEndu(point[3]);
            this.petInfo.getBfp().setAgi(point[4]);
            this.petInfo.getInitbfp().setCons(this.petInfo.getBfp().getCons());
            this.petInfo.getInitbfp().setIq(this.petInfo.getBfp().getIq());
            this.petInfo.getInitbfp().setStr(this.petInfo.getBfp().getStr());
            this.petInfo.getInitbfp().setEndu(this.petInfo.getBfp().getEndu());
            this.petInfo.getInitbfp().setAgi(this.petInfo.getBfp().getAgi());
        }
    }

    public int initGrowRate() {
        if (null != this.petInfo && null != this.petAttr) {
            ArrayList<Integer> growRates = this.petAttr.getGrowrate();
            if (growRates.size() != 7) {
                return -1;
            } else if (this.petAttr.getGrowrateconst() > 0) {
                this.petInfo.setGrowrate(this.petAttr.getGrowrateconst());
                return this.petAttr.getGrowrateconst();
            } else {
                int r = Mkdb.random().nextInt(growRates.size());
                if (r >= 0 && r < growRates.size()) {
                    this.petInfo.setGrowrate((Integer)growRates.get(r));
                    return (Integer)growRates.get(r);
                } else {
                    this.petInfo.setGrowrate((Integer)growRates.get(0));
                    return (Integer)growRates.get(0);
                }
            }
        } else {
            return -1;
        }
    }

    public void genPetSkill(PetInfo petInfo) {
        Pet pet = Pet.getPet(petInfo);
        pet.getBattleskills().clear();

        for(SkillRate skillRate : this.petAttr.getSkills()) {
            if (Misc.checkRate(999, skillRate.rate)) {
                pet.addSkill(skillRate.skillid, -1L, 0, 0);
            }
        }

    }

    public static int getApt(int max, int min) {
        if (max == min) {
            return max;
        } else if (max < min) {
            return -1;
        } else {
            int apt = Misc.getRandomBetween(min, max);
            return apt;
        }
    }

    public void setBornAttackApt(int attackapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (attackapt < 0) {
                if (this.petAttr.getAttackaptconst() > 0) {
                    attackapt = this.petAttr.getAttackaptconst();
                } else {
                    attackapt = getApt(this.petAttr.getAttackaptmax(), this.petAttr.getAttackaptmin());
                }
            }

            if (attackapt >= 0) {
                this.petInfo.setBornattackapt(attackapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornAttackApt] 参数错误");
        }
    }

    public void setBornDefendApt(int defendapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (defendapt < 0) {
                if (this.petAttr.getDefendaptconst() > 0) {
                    defendapt = this.petAttr.getDefendaptconst();
                } else {
                    defendapt = getApt(this.petAttr.getDefendaptmax(), this.petAttr.getDefendaptmin());
                }
            }

            if (defendapt >= 0) {
                this.petInfo.setBorndefendapt(defendapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornDefendApt] 参数错误");
        }
    }

    public void setBornPhyforceApt(int phyforceapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (phyforceapt < 0) {
                if (this.petAttr.getPhyforceaptconst() > 0) {
                    phyforceapt = this.petAttr.getPhyforceaptconst();
                } else {
                    phyforceapt = getApt(this.petAttr.getPhyforceaptmax(), this.petAttr.getPhyforceaptmin());
                }
            }

            if (phyforceapt >= 0) {
                this.petInfo.setBornphyforceapt(phyforceapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornPhyforceApt] 参数错误");
        }
    }

    public void setBornMagicApt(int magicapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (magicapt < 0) {
                if (this.petAttr.getMagicaptconst() > 0) {
                    magicapt = this.petAttr.getMagicaptconst();
                } else {
                    magicapt = getApt(this.petAttr.getMagicaptmax(), this.petAttr.getMagicaptmin());
                }
            }

            if (magicapt >= 0) {
                this.petInfo.setBornmagicapt(magicapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornMagicApt] 参数错误");
        }
    }

    public void setBornSpeedApt(int speedapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (speedapt < 0) {
                if (this.petAttr.getSpeedaptconst() > 0) {
                    speedapt = this.petAttr.getSpeedaptconst();
                } else {
                    speedapt = getApt(this.petAttr.getSpeedaptmax(), this.petAttr.getSpeedaptmin());
                }
            }

            if (speedapt >= 0) {
                this.petInfo.setBornspeedapt(speedapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornSpeedApt] 参数错误");
        }
    }

    public void setBornDodgeApt(int dodgeapt) {
        if (null != this.petAttr && null != this.petInfo) {
            if (dodgeapt < 0) {
                dodgeapt = getApt(0, 0);
            }

            if (dodgeapt >= 0) {
                this.petInfo.setBorndodgeapt(dodgeapt);
            }

        } else {
            Module.logger.warn("[CalcPetAttr.setBornDodgeApt] 参数错误 ");
        }
    }

    public int getLifeFromConfig() {
        return null == this.petAttr ? 0 : this.petAttr.getLife();
    }

    public static int doBaseScoreCalculate(Pet pet) {
        double score = (double)0.0F;
        Role epet = new PetImpl(pet.getPetInfo());
        int allPoint = epet.getAgi() + epet.getCons() + epet.getEndu() + epet.getIq() + epet.getStr();
        score += (double)allPoint * fire.pb.scoremanager.Module.getInstance().getCoe(9);
        return (int)score;
    }

    public static double doCalculate(Pet pet) {
        double score = (double)0.0F;
        Role epet = new PetImpl(pet.getPetInfo());
        Map<Integer, SPetAbilityScore> petScoreCnf = fire.pb.scoremanager.Module.getInstance().getPetAbility();

        for(SPetAbilityScore petScore : petScoreCnf.values()) {
            double attrValue = getCurrentAttrValue(pet, petScore.id, epet);
            score += attrValue * petScore.score;
        }

        int allPoint = epet.getAgi() + epet.getCons() + epet.getEndu() + epet.getIq() + epet.getStr();
        score += (double)allPoint * fire.pb.scoremanager.Module.getInstance().getCoe(9);
        int skillScore = 0;

        for(int skillId : pet.getBattleskillIds()) {
            skillScore += PetManager.getInstance().getSkillScore(skillId);
        }

        int internalScore = 0;

        for(int InternalId : pet.getBattleInternalIds()) {
            internalScore += PetManager.getInstance().getSkillScore(InternalId);
        }

        score = score + (double)skillScore + (double)internalScore;
        int growRate = pet.getPetInfo().getGrowrate() - 952;
        if (growRate < 0) {
            growRate = 0;
        }

        score += (double)growRate * fire.pb.scoremanager.Module.getInstance().getCoe(12) / (double)1000.0F;
        return score;
    }

    private static double getCurrentAttrValue(Pet pet, int attributeId, Role epet) {
        switch (attributeId) {
            case 60:
                return (double)epet.getMaxHp();
            case 130:
                return (double)epet.getAttack();
            case 140:
                return (double)epet.getDefend();
            case 150:
                return (double)epet.getMagicAttack();
            case 160:
                return (double)epet.getMagicDef();
            case 200:
                return (double)epet.getSpeed();
            case 220:
                return (double)epet.getDodge();
            case 1430:
                return (double)pet.getUseLevel();
            case 1440:
                return (double)pet.getAttackapt();
            case 1450:
                return (double)pet.getDefendapt();
            case 1460:
                return (double)pet.getPhyforceapt();
            case 1470:
                return (double)pet.getMagicapt();
            case 1480:
                return (double)pet.getSpeedapt();
            case 1490:
                return (double)pet.getDodgeapt();
            case 1500:
                return (double)pet.getGrowrate() / (double)1000.0F;
            default:
                return (double)0.0F;
        }
    }

    public static void graspPekSkillWhileUplevel(long roleId, int petKey) {
        PetColumn petCol = new PetColumn(roleId, 1, false);
        PetInfo petInfo = petCol.getPetInfo(petKey);
        if (petInfo != null) {
            Pet pet = Pet.getPet(petInfo);
            if (pet.canLearnNewSkillWhileUpLevel()) {
                int graspSkillId = getGraspSkillID(pet.getBattleskillIds(), pet.getPetAttr());
                if (-1 != graspSkillId) {
                    boolean succ = petCol.addSkill(petKey, graspSkillId, 0, 0);
                    if (succ) {
                        SRefreshPetSkill send = new SRefreshPetSkill();
                        send.petkey = petKey;
                        pet.fillSRefreshPetSkill(send);
                        Onlines.getInstance().send(roleId, send);
                        List<String> param = new ArrayList();
                        param.add(petInfo.getName());
                        FightSkillConfig skillConfig = fire.pb.skill.Module.getInstance().getFightSkillConfig(graspSkillId);
                        if (null != skillConfig) {
                            String colorRgb = Module.getInstance().getPetColorRGB(Pet.getClour(1));
                            param.add(colorRgb);
                            param.add(skillConfig.getSkillName());
                            MessageMgr.psendMsgNotifyWhileCommit(roleId, 141705, param);
                            String rolename = Properties.selectRolename(roleId);
                            List<String> params = MessageMgr.getStringList(new Object[]{rolename, pet.getPetAttr().getName(), colorRgb, skillConfig.getSkillName()});
                            SceneManager.psendAroundWhileCommit(roleId, MessageMgr.getMsgNotify(142722, 0, params));
                        }
                    }
                }
            }
        }
    }

    private static int getGraspSkillID(List<Integer> skills, PetAttr petAttr) {
        List<SkillRate> bornSkills = petAttr.getSkills();
        List<Integer> graspSkills = new ArrayList();

        for(SkillRate rate : bornSkills) {
            if (!skills.contains(rate.getSkillid())) {
                graspSkills.add(rate.getSkillid());
            }
        }

        if (graspSkills.size() == 0) {
            return -1;
        } else {
            return (Integer)graspSkills.get(Misc.getRandomBetween(0, graspSkills.size() - 1));
        }
    }
}
