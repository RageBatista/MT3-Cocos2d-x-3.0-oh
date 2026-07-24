//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import fire.log.YYLogger;
import fire.log.beans.RoleCreateBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.CCreateRole;
import fire.pb.GameSystemConfig;
import fire.pb.PInitRoleProp;
import fire.pb.RoleConfigManager;
import fire.pb.SCreateRole;
import fire.pb.SCreateRoleError;
import fire.pb.PropConf.Battle;
import fire.pb.battle.ai.BattleAIManager;
import fire.pb.buff.continual.ConstantlyBuffConfig;
import fire.pb.event.CreateRoleEvent;
import fire.pb.event.Poster;
import fire.pb.friends.Module;
import fire.pb.hook.PInitHookDataProc;
import fire.pb.http.HttpCallBackHandler;
import fire.pb.huoban.HuoBanFactory;
import fire.pb.item.Equip;
import fire.pb.item.EquipItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.main.ConfigManager;
import fire.pb.main.Gs;
import fire.pb.mission.SLineTask;
import fire.pb.mysql.HikariCPUtil;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.statistics.StatisticUtil;
import fire.pb.util.DateValidate;
import fire.pb.util.FireProp;
import fire.pb.util.Misc;
import gnet.link.Onlines;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import mkdb.Trace;
import mkdb.util.UniqName;
import mkio.Protocol;
import com.fasterxml.jackson.databind.JsonNode;
import fire.util.JsonUtil;
import org.apache.http.client.methods.HttpGet;
import org.apache.log4j.Logger;
import xbean.AUUserInfo;
import xbean.BasicFightProperties;
import xbean.BattleAI;
import xbean.Pod;
import xbean.Properties;
import xbean.RoleSpace;
import xbean.RoleUpdateTime;
import xbean.User;
import xtable.Auuserinfo;
import xtable.Rolename2key;
import xtable.Roleonoffstate;
import xtable.Rolespaces;
import xtable.Roleupdatetimetab;

public class PCreateRole extends Procedure {
    private static final Logger logger = Logger.getLogger("SYSTEM");
    public static final String address = FireProp.getStringValue("sys", "sys.zhaomu.address");
    public static final String func = "/enlist/submit_code";
    public static int maxRoleNum = FireProp.getIntValue(ConfigManager.getInstance().getPropConf("sys"), "sys.maxRoleNum");
    public static int maxCreateRoleNum = 1;
    private long newRoleID;
    private final Protocol thisProtocol;
    private final int userID;
    private final String name;
    private final int school;
    private final int shape;
    private final ArrayList<Integer> initequips;

    public PCreateRole(CCreateRole protocol, int userID, ArrayList<Integer> initequips) {
        this.userID = userID;
        this.name = protocol.name;
        this.school = protocol.school;
        this.shape = protocol.shape;
        this.thisProtocol = protocol;
        this.initequips = initequips;
    }

    public long getNewRoleID() {
        return this.newRoleID;
    }

    private boolean sendError(int err) {
        SCreateRoleError res = new SCreateRoleError();
        res.err = err;
        return Onlines.getInstance().sendResponse(this.thisProtocol, res);
    }

    private static void initBasicFightProperties(BasicFightProperties b, RoleModData m) {
        b.setAgi((short)m.agiinit);
        b.setCons((short)m.consinit);
        b.setEndu((short)m.enduinit);
        b.setIq((short)m.iqinit);
        b.setStr((short)m.strinit);
    }

    private boolean InsertMysqlRelation(long roleId, String rolename, int shapeid, int level, int userId) {
        if (rolename != null && !rolename.trim().isEmpty() && rolename.length() <= 50) {
            Connection conn = null;
            PreparedStatement roleStmt = null;
            PreparedStatement bindStmt = null;

            boolean var16;
            try {
                conn = HikariCPUtil.getConnection();
                conn.setAutoCommit(false);
                String roleSql = "INSERT INTO `role`(roleid, name, avatar, level) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, avatar=?, level=?";
                roleStmt = conn.prepareStatement(roleSql);
                roleStmt.setLong(1, roleId);
                roleStmt.setString(2, rolename);
                roleStmt.setInt(3, shapeid);
                roleStmt.setInt(4, level);
                roleStmt.setString(5, rolename);
                roleStmt.setInt(6, shapeid);
                roleStmt.setInt(7, level);
                int ret1 = roleStmt.executeUpdate();
                Module.logger.info("[" + roleId + "]InsertMysqlRelation role表成功，ret = " + ret1);
                if (ret1 <= 0) {
                    conn.rollback();
                    boolean e = false;
                    return e;
                }

                String checkUserSql = "SELECT COUNT(*) FROM `user_account` WHERE id = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkUserSql);
                checkStmt.setInt(1, userId);
                ResultSet rs = checkStmt.executeQuery();
                rs.next();
                int userExists = rs.getInt(1);
                rs.close();
                checkStmt.close();
                if (userExists != 0) {
                    Module.logger.info("[" + roleId + "]确认用户ID=" + userId + "在user_account表中存在，继续创建角色绑定");
                    String bindSql = "INSERT INTO `user_bind`(userid, serverid, playerid, playername, charge, daycharge) VALUES (?, ?, ?, ?, 0.00, 0.00) ON DUPLICATE KEY UPDATE playername=?";
                    bindStmt = conn.prepareStatement(bindSql);
                    bindStmt.setInt(1, userId);
                    bindStmt.setString(2, Gs.serverid);
                    bindStmt.setLong(3, roleId);
                    bindStmt.setString(4, rolename);
                    bindStmt.setString(5, rolename);
                    int ret2 = bindStmt.executeUpdate();
                    Module.logger.info("[" + roleId + "]InsertMysqlRelation user_bind表成功，ret = " + ret2);
                    conn.commit();
                    if (ret1 > 1) {
                        Module.logger.warn("角色[" + roleId + "]空间mysql数据id已占用,强制更新为新id数据！");
                    }

                    boolean var18 = true;
                    return var18;
                }

                Module.logger.error("[" + roleId + "]用户ID=" + userId + "在user_account表中不存在，无法创建角色");
                conn.rollback();
                var16 = false;
            } catch (SQLException ex) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException e) {
                        Module.logger.error("[" + roleId + "]事务回滚失败", e);
                    }
                }

                Module.logger.error("[" + roleId + "]InsertMysqlRelation失败", ex);
                boolean ret1 = false;
                return ret1;
            } finally {
                if (roleStmt != null) {
                    try {
                        roleStmt.close();
                    } catch (SQLException var42) {
                    }
                }

                if (bindStmt != null) {
                    try {
                        bindStmt.close();
                    } catch (SQLException var41) {
                    }
                }

                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        Module.logger.error("[" + roleId + "]关闭数据库连接失败", e);
                    }
                }

            }

            return var16;
        } else {
            Module.logger.error("[" + roleId + "]无效的角色名: " + rolename);
            return false;
        }
    }

    public boolean process() {
        SCreateRole snd = new SCreateRole();
        String lowerCaseName = this.name.toLowerCase();
        if (!UniqName.allocate("role", lowerCaseName)) {
            this.sendError(4);
            return false;
        } else {
            User u = xtable.User.get(this.userID);
            if (null != u) {
                int roleNum = 0;

                for(Long rid : u.getIdlist()) {
                    Properties prop = xtable.Properties.select(rid);
                    if (prop.getDeletetime() == 0L) {
                        ++roleNum;
                    }
                }

                if (roleNum >= maxCreateRoleNum) {
                    this.sendError(5);
                    return false;
                }
            }

            long now = Calendar.getInstance().getTimeInMillis();
            RoleConfig config = RoleConfigManager.getRoleConfigBySchoolID(this.school);
            SCreateRoleConfig createConfig = RoleConfigManager.getCreateRoleConfig(this.shape);
            RoleModData moddata = RoleConfigManager.getRoleModData(1);
            Properties pro = Pod.newProperties();
            pro.setCreatetime(now);
            pro.setOnlinetime(now);
            pro.setOfflinetime(now);
            pro.setRolename(this.name);
            pro.setSchool(this.school);
            pro.setShape(this.shape);
            pro.setRace(1);
            pro.setSex(createConfig.sex);
            pro.setLevel(config.level);
            pro.setExp(0L);
            pro.setTitle(-1);
            pro.setSceneid((long)config.mapid);
            pro.setUserid(this.userID);
            if (pro.getSysconfigmap().size() == 0) {
                GameSystemConfig.resetSysConfig(pro);
            }

            pro.getSysconfigmap().put(5, FireProp.getIntValue("sys", "sys.maxScreenShowNum"));
            if (pro.getLineconfigmap().size() == 0) {
                Map<Integer, SLineTask> instanceTask = ConfigManager.getInstance().getConf(SLineTask.class);
                if (instanceTask != null) {
                    for(SLineTask linetask : instanceTask.values()) {
                        pro.getLineconfigmap().put(linetask.minlevel, 0);
                    }
                }
            }

            if (pro.getAddpointfp().getAgi_save().size() == 0 || pro.getAddpointfp().getCons_save().size() == 0 || pro.getAddpointfp().getEndu_save().size() == 0 || pro.getAddpointfp().getIq_save().size() == 0 || pro.getAddpointfp().getStr_save().size() == 0) {
                GameSystemConfig.resetRolePropAddPointFp(pro);
            }

            if (pro.getPoint().size() == 0) {
                GameSystemConfig.resetRolePropPoint(pro);
            }

            int posx = Misc.getRandomBetween(config.mapx, config.mapx + config.regionx);
            int posy = Misc.getRandomBetween(config.mapy, config.mapy + config.regiony);
            pro.setPosx(posx);
            pro.setPosy(posy);
            pro.setSp(Battle.PROP_SP_INITIAL);
            BasicFightProperties bfp = pro.getBfp();
            initBasicFightProperties(bfp, moddata);
            ArrayList<Integer> points = null;
            switch (config.defaultscheme) {
                case 1:
                    points = config.addpoint;
                    break;
                case 2:
                    points = config.addpoint2;
                    break;
                case 3:
                    points = config.addpoint3;
                    break;
                default:
                    points = config.addpoint;
            }

            if (pro.getLevel() == 1) {
                bfp.setAgi((short)(bfp.getAgi() + 1 + (Integer)points.get(4)));
                bfp.setCons((short)(bfp.getCons() + 1 + (Integer)points.get(0)));
                bfp.setEndu((short)(bfp.getEndu() + 1 + (Integer)points.get(3)));
                bfp.setIq((short)(bfp.getIq() + 1 + (Integer)points.get(1)));
                bfp.setStr((short)(bfp.getStr() + 1 + (Integer)points.get(2)));
            } else {
                for(int i = 1; i < 4; ++i) {
                    pro.getPoint().put(i, 5);
                }
            }

            for(int aiid : BattleAIManager.getInstance().getRoleDefaultFighteAIIDs(this.school)) {
                BattleAI newai = Pod.newBattleAI();
                newai.setId(aiid);
                pro.getFighteai().add(newai);
            }

            final long newRoleID = xtable.Properties.insert(pro);
            if (null == u) {
                u = Pod.newUser();
                u.setCreatetime(now);
                xtable.User.insert(this.userID, u);
                StatisticUtil.setUserFirsttimeIntoWorld(this.userID, now);
            }

            u.setPrevloginroleid(newRoleID);
            u.getIdlist().add(newRoleID);
            AUUserInfo auUserInfo = Auuserinfo.select(this.userID);
            if (auUserInfo != null) {
                pro.setPlatformuid(auUserInfo.getUsername());
            } else {
                Trace.error("创建 role.userid 时 auuserinfo 不存在:" + this.userID);
            }

            try {
                Roleonoffstate.remove(newRoleID);
                Roleonoffstate.add(newRoleID, 0);
                logger.info("角色[" + newRoleID + "]创建完成，状态已初始化为0，确保正常登录");
            } catch (Exception e) {
                logger.error("角色[" + newRoleID + "]状态初始化失败: " + e.getMessage(), e);
            }

            snd.newinfo.roleid = newRoleID;
            snd.newinfo.rolename = this.name;
            snd.newinfo.school = this.school;
            snd.newinfo.shape = this.shape;
            snd.newinfo.level = pro.getLevel();
            snd.newinfo.rolecreatetime = now;
            if (ConfigManager.getUseMysql() && !this.InsertMysqlRelation(newRoleID, this.name, this.shape, pro.getLevel(), this.userID)) {
                logger.error("PCreateRole.InsertMysqlRelation 失败! 角色创建失败");
                return false;
            } else if (Rolename2key.select(this.name) != null) {
                this.sendError(4);
                return false;
            } else {
                RoleSpace rs = Rolespaces.get(newRoleID);
                if (rs != null) {
                    return false;
                } else {
                    RoleSpace newrs = Pod.newRoleSpace();
                    newrs.setGift(0);
                    newrs.setPopularity(0);
                    newrs.setRecvgift(0);
                    newrs.setGetgiftnum(0);
                    newrs.setGetgifttime(0L);
                    Rolespaces.insert(newRoleID, newrs);
                    Rolename2key.insert(this.name, newRoleID);
                    if (this.initequips != null) {
                        ItemMaps equip = fire.pb.item.Module.getInstance().getItemMaps(newRoleID, 3, false);

                        for(int i = 0; i < this.initequips.size(); ++i) {
                            EquipItem ei = (EquipItem)fire.pb.item.Module.getInstance().getItemManager().genItemBase((Integer)this.initequips.get(i), 1);
                            if (ei != null) {
                                equip.doAddItem(ei, -1, "物品赠送", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, 0);
                            }
                        }
                    }

                    if (config.presents != null) {
                        ItemMaps bag = fire.pb.item.Module.getInstance().getItemMaps(newRoleID, 1, false);
                        if (config.presents.size() == config.nums.size()) {
                            for(int i = 0; i < config.presents.size(); ++i) {
                                bag.doAddItem((Integer)config.presents.get(i), (Integer)config.nums.get(i), "物品赠送", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, 0);
                            }
                        } else {
                            fire.pb.item.Module.getInstance().getLogger().error("人物职业配置表id=" + this.school + "出错,赠送物品和数量不匹配");
                        }
                    }

                    Equip equip = new Equip(newRoleID, false);
                    SceneSkillRole nrole = SkillManager.getSceneSkillRole(newRoleID);

                    for(ItemBase item : equip) {
                        if (item instanceof EquipItem && ((EquipItem)item).getExtInfo().getEndure() > 0) {
                            Map<Integer, Float> effects = new HashMap();
                            List<ConstantlyBuffConfig> buffs = new LinkedList();
                            ((EquipItem)item).getEffectsAndBuffs(effects, buffs);
                            xbean.Equip equipAttr = ((EquipItem)item).getExtInfo();
                            List<Integer> skills = new ArrayList();
                            if (equipAttr.getSkill() > 0) {
                                skills.add(equipAttr.getSkill());
                            }

                            if (equipAttr.getEffect() > 0) {
                                skills.add(equipAttr.getEffect());
                            }

                            nrole.equip(((EquipItem)item).getEquipType(), effects, skills);
                        }
                    }

                    (new PInitRoleProp(newRoleID)).call();
                    HuoBanFactory.getFactory().initRoleHuoban(newRoleID);
                    (new PInitHookDataProc(newRoleID)).call();
                    logger.info("创建角色 :\t" + this.name + "\t" + this.shape + "\troleID:" + newRoleID + "\tuserID:" + this.userID);
                    StatisticUtil.setRoleCreateTime(newRoleID, now);
                    Poster.getPoster().dispatchEvent(new CreateRoleEvent(newRoleID, this.school));
                    Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(newRoleID));
                    RoleUpdateTime roleUpdateTime = Roleupdatetimetab.get(newRoleID);
                    if (roleUpdateTime == null) {
                        roleUpdateTime = Pod.newRoleUpdateTime();
                        Roleupdatetimetab.insert(newRoleID, roleUpdateTime);
                    }

                    roleUpdateTime.setDateupdatetime(System.currentTimeMillis());
                    roleUpdateTime.setWeekupdatetime(DateValidate.getWeekNumber());
                    YYLogger.OpRegLog(this.userID, newRoleID, 1);
                    YYLogger.createRoleLog(newRoleID, new RoleCreateBean(pro.getShape(), pro.getSchool()));
                    CCreateRole crproto = (CCreateRole)this.thisProtocol;
                    if (ConfigManager.isOpenRecruit && !crproto.code.isEmpty() && !crproto.code.equals("") && !crproto.code.equals("0")) {
                        String buildurl = String.format("http://%1$s%2$s?code=%3$s&new_serverid=%4$s&new_roleid=%5$s", address, "/enlist/submit_code", crproto.code, Gs.serverid, newRoleID);
                        HttpGet request = new HttpGet(buildurl);
                        Gs.getHttpClient().execute(request, new HttpCallBackHandler() {
                            protected boolean process(JsonNode json) {
                                String errno = json.get("errno").asText();
                                if (!errno.isEmpty() && !errno.equals("")) {
                                    PCreateRole.logger.warn("PCreateRole.HttpCallBackHandler:errno=" + errno + ",message=" + json.get("message").asText());
                                } else {
                                    PCreateRole.logger.info("PCreateRole.HttpCallBackHandler:角色[" + newRoleID + "]发送招募信息成功！");
                                }

                                return true;
                            }
                        });
                    } else {
                        logger.info("PCreateRole.HttpCallBackHandler:角色[" + newRoleID + "]没有招募信息.");
                    }

                    try {
                        boolean sendResult = Onlines.getInstance().sendResponse(this.thisProtocol, snd);
                        if (sendResult) {
                            logger.info("角色[" + newRoleID + "]创建成功响应已发送给客户端");
                        } else {
                            logger.warn("角色[" + newRoleID + "]创建成功，但响应发送可能失败");

                            try {
                                boolean backupResult = Onlines.getInstance().send((long)this.userID, snd);
                                if (backupResult) {
                                    logger.info("角色[" + newRoleID + "]通过备用方式发送响应成功");
                                }
                            } catch (Exception backupEx) {
                                logger.error("角色[" + newRoleID + "]备用发送方式也失败: " + backupEx.getMessage());
                            }
                        }
                    } catch (Exception e) {
                        logger.error("角色[" + newRoleID + "]发送创建响应时发生异常: " + e.getMessage(), e);
                    }

                    try {
                        gnet.link.User gnetUser = Onlines.getInstance().getConnectedUsers().getUserByUserId(this.userID);
                        if (gnetUser != null) {
                            gnetUser.sendRoleList(false);
                            logger.info("角色[" + newRoleID + "]创建后已主动刷新客户端角色列表");
                        } else {
                            logger.warn("角色[" + newRoleID + "]创建成功，但用户[" + this.userID + "]不在在线列表中，无法刷新角色列表");
                        }
                    } catch (Exception e) {
                        logger.error("角色[" + newRoleID + "]创建成功，但刷新角色列表失败: " + e.getMessage(), e);
                    }

                    return true;
                }
            }
        }
    }
}
