//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.PropRole;
import fire.pb.activity.timernpc.TimerNpcService;
import fire.pb.circletask.CircleTask;
import fire.pb.circletask.anye.RoleAnYeTask;
import fire.pb.clan.ClanUtils;
import fire.pb.compensation.CompensationManager;
import fire.pb.fushi.FushiManager;
import fire.pb.main.ConfigManager;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import fire.pb.npc.NpcServiceCond.Condition;
import fire.pb.school.shouxi.ProfessionLeaderManager;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.TreeMap;
import java.util.Vector;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.WeiBoNotify;
import xtable.Role2weibonotify;

public class NpcServiceManager {
    private static NpcServiceManager _instance = new NpcServiceManager();
    private static final Logger logger = Logger.getLogger("MAPMAIN");
    private NavigableMap<Integer, SNpcServiceConfig> npcServiceMap = new TreeMap();
    private NavigableMap<Integer, SServiceConds> serviceDetailMap = new TreeMap();
    private NavigableMap<Integer, SNpcServiceMapping> npcServiceMappingMap = new TreeMap();
    private Map<Integer, Condition> allcondsmap = new HashMap();
    private Vector<Integer> gmclosedservices = new Vector();

    private NpcServiceManager() {
    }

    public static synchronized NpcServiceManager getInstance() {
        return _instance;
    }

    public static void reload() throws Exception {
        NpcServiceManager instance = new NpcServiceManager();
        instance.init();
        synchronized(NpcServiceManager.class) {
            _instance = instance;
        }
    }

    void init() throws Exception {
        ConfigManager cm = ConfigManager.getInstance();
        this.npcServiceMap = cm.getConf(SNpcServiceConfig.class);
        logger.info("NPC服务配置表加载完毕。一共载入服务NPC" + this.npcServiceMap.size() + "个");
        this.serviceDetailMap = cm.getConf(SServiceConds.class);
        logger.info("NPC服务描述表加载完毕。一共载入服务 " + this.serviceDetailMap.size() + "条");
        this.npcServiceMappingMap = cm.getConf(SNpcServiceMapping.class);
        logger.info("NPC服务映射表加载完毕。一共载入服务映射" + this.npcServiceMappingMap.size() + "条");
        this.registerAllConds(cm.getConf(SAllConds.class));
    }

    public void registerAllConds(NavigableMap<Integer, SAllConds> condsmap) {
        if (condsmap != null) {
            for(int key : condsmap.keySet()) {
                SAllConds cond = (SAllConds)condsmap.get(key);

                try {
                    Condition condclass = (Condition)Class.forName("fire.pb.npc.NpcServiceCond." + cond.condname).getConstructor().newInstance();
                    this.allcondsmap.put(key, condclass);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        }
    }

    public final SNpcServiceConfig getServiceConfigByNpcID(int npcid) {
        return (SNpcServiceConfig)this.npcServiceMap.get(npcid);
    }

    public final SNpcServiceMapping getServiceMappingByServiceID(int serviceid) {
        return (SNpcServiceMapping)this.npcServiceMappingMap.get(serviceid);
    }

    public void openService(Integer serviceid) {
        this.gmclosedservices.remove(serviceid);
    }

    public void closeService(Integer serviceid) {
        this.gmclosedservices.add(serviceid);
    }

    public boolean ingmclosedservice(Integer serviceid) {
        return this.gmclosedservices.contains(serviceid);
    }

    public static int getNpcIDByKey(long key) {
        Npc npc = SceneNpcManager.selectNpcByKey(key);
        return null == npc ? -1 : npc.getNpcID();
    }

    private static final ArrayList<Integer> getDynamicServicesIDS(long npckey, long roleid) {
        ArrayList<Integer> result = new ArrayList();
        Npc curnpc = SceneNpcManager.selectNpcByKey(npckey);
        if (curnpc == null) {
            logger.warn("role:" + roleid + "SceneNpcManager select npc=" + npckey + ",is null!");
            return result;
        } else {
            int npcid = curnpc.getNpcID();

            try {
                CircleTask.addCTDynamicServices(roleid, npckey, result);
                ProfessionLeaderManager.addDynamicServices(roleid, npckey, npcid, result);
                CompensationManager.getInstance().addDynamicServices(roleid, npcid, result);
                ClanUtils.addDynamicServices(roleid, npckey, npcid, result);
                TimerNpcService.addCTDynamicServices(roleid, npcid, npckey, result);
                Module.addDynamicServices(npcid, result);
            } catch (Exception e) {
                logger.error("exception when add dynamic service", e);
            }

            return result;
        }
    }

    public final List<Integer> getServicesIDSByNpcKey(long roleid, long npckey) {
        return this.getServicesIDS(roleid, npckey, true);
    }

    public final List<Integer> getShowServicesIDSByNpcKey(long roleid, long npckey) {
        return this.getServicesIDS(roleid, npckey, false);
    }

    private final List<Integer> getServicesIDS(long roleid, long npckey, boolean getChildService) {
        List<Integer> results = new ArrayList();
        List<Integer> dynamicResults = getDynamicServicesIDS(npckey, roleid);
        results.addAll(dynamicResults);
        int npcid = getNpcIDByKey(npckey);
        SNpcServiceConfig config = (SNpcServiceConfig)this.npcServiceMap.get(npcid);
        if (null != config && null != config.getServices()) {
            results.addAll(config.getServices());
        }

        List<Integer> toAdd = new ArrayList();
        List<Integer> toRemove = new ArrayList();

        for(int serviceid : results) {
            if (!getChildService && !this.isServiceShow(roleid, serviceid)) {
                toRemove.add(serviceid);
            } else {
                SServiceConds allconds = this.getServiceConds(serviceid);
                if (getChildService && allconds != null && allconds.childservice != null) {
                    toAdd.addAll(allconds.childservice);
                }
            }
        }

        if (getChildService) {
            results.addAll(toAdd);
        }

        if (!getChildService) {
            results.removeAll(toRemove);
        }

        if (npcid == 10964) {
            this.dealReturnFuShi(roleid, results);
        }

        results.removeAll(this.gmclosedservices);
        RoleAnYeTask.addDynamicServices(roleid, npckey, results);
        return results;
    }

    private void dealReturnFuShi(long roleid, List<Integer> validlist) {
        int userid = (new PropRole(roleid, true)).getUserid();
        int returnFuShi = FushiManager.getInstance().getFuShiFanHuan(userid);
        if (returnFuShi > 0) {
            validlist.add(1820);
        }

        WeiBoNotify notify = Role2weibonotify.select(roleid);
        if (notify != null && notify.getTakeawardflag() == 1) {
            validlist.add(0, 1987);
        }

    }

    private boolean isServiceShow(long roleid, int serviceId) {
        SServiceConds allconds = this.getServiceConds(serviceId);
        if (allconds != null && !allconds.conditionids.isEmpty()) {
            for(SNpcCond cond : allconds.conditionids) {
                Condition condclass = (Condition)this.allcondsmap.get(cond.condid);
                if (condclass == null) {
                    logger.debug("没有配置此id的条件  id=" + cond.condid);
                    return false;
                }

                if (!condclass.CheckCond(roleid, cond.args1, cond.args2)) {
                    return false;
                }
            }
        }

        return true;
    }

    public SServiceConds getServiceConds(int serviceid) {
        return (SServiceConds)this.serviceDetailMap.get(serviceid);
    }

    public boolean hasServiceByNpcKey(long roleid, long npckey, int... serviceids) {
        List<Integer> services = this.getServicesIDSByNpcKey(roleid, npckey);

        for(int serviceid : serviceids) {
            if (!services.contains(serviceid)) {
                return false;
            }
        }

        return true;
    }

    public static void sendNpcDialog(boolean proctrue, long roleid, long npckey, int msgid, ArrayList<Long> args) {
        if (null != args) {
            Npc npc = SceneNpcManager.selectNpcByKey(npckey);
            if (null != npc) {
                SSendNpcMsg send = new SSendNpcMsg();
                send.npcid = npc.getNpcID();
                send.npckey = npckey;
                send.msgid = msgid;
                send.args = args;
                if (proctrue) {
                    Procedure.psendWhileCommit(roleid, send);
                } else {
                    Procedure.psendWhileRollback(roleid, send);
                }

            }
        }
    }

    public static void sendNpcDialog(long roleid, long npckey, int msgid, ArrayList<Long> args) {
        if (null != args) {
            Npc npc = SceneNpcManager.selectNpcByKey(npckey);
            if (null != npc) {
                SSendNpcMsg send = new SSendNpcMsg();
                send.npcid = npc.getNpcID();
                send.npckey = npckey;
                send.msgid = msgid;
                send.args = args;
                Onlines.getInstance().send(roleid, send);
            }
        }
    }

    public static int transfNpcIDByKey(long npcKey) {
        Npc npc = SceneNpcManager.selectNpcByKey(npcKey);
        return null == npc ? -1 : npc.getNpcID();
    }
}
