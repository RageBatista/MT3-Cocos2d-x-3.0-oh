package fire.pb.map;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import fire.log.Logger;
import fire.msp.npc.GCreateNPCByGridScale;
import fire.msp.npc.GCreateNPCByMap;
import fire.msp.npc.GCreateNPCByPos;
import fire.msp.npc.GCreateNPCWithRoleids;
import fire.msp.npc.GCreateNpcInRegion;
import fire.pb.GsClient;
import fire.pb.PropConf.Sys;
import fire.pb.npc.PRemoveNpcFromGS;
import fire.pb.scene.MapUtil;
import mkdb.Transaction;


public class SceneNpcManager{
	public final static Logger logger = Logger.getLogger("MAPMAIN");
	private SceneNpcManager(){}
	private long nextkey=Integer.MAX_VALUE;//FIXME 地图的nextkey从0开始，逻辑从MAX_INTEGER开始，应该够用
	private static volatile SceneNpcManager instance = new SceneNpcManager();
	private Map<Long,Npc> npcs = new ConcurrentHashMap<Long, Npc>();
	
	
	/**
	 * 获得场景NPC管理器
	 * @返回
	 */
	public static SceneNpcManager getInstance(){
		
		return instance;
	}
	
	public synchronized long getNextId(){
		nextkey++;
		return nextkey;
	}
	
	public Npc createAddNewNpc(fire.msp.npc.NpcInfo createinfo)
	{
		Npc npc = new Npc(createinfo.npckey, false);
		npc.updateNpcInfo(createinfo);
		npcs.put(createinfo.npckey, npc);
		return npc;
	}
	public Map<Long,Npc> getNpcs()
	{
		return npcs;
	}

	public Map<Long, Npc> getNpcsByMap(int mapId) {
		Map<Long, Npc> result = new HashMap<Long, Npc>();
		for (Map.Entry<Long, Npc> entry : npcs.entrySet()) {
			Npc npc = entry.getValue();
			if (npc != null && npc.getMapId() == mapId) {
				result.put(entry.getKey(), npc);
			}
		}
		return result;
	}
	
	/**
	 * 根据 npc key 获得Npc实例
	 * ！只能在存储过程内调用
	 * @lock npclock
	 * @参数键
	 * @返回
	 */
	public static Npc getNpcByKey(long npckey){
		
		Npc npc = getInstance().getNpcs().get(npckey);
		if(npc == null)
			return null;
		
		xbean.NpcInfo npcinfo =  xtable.Npcs.get(npckey);
		if(npcinfo == null)
		{
			npcinfo = xbean.Pod.newNpcInfo();
			xtable.Npcs.add(npckey, npcinfo);
		}
		npc.setNpcinfo(npcinfo);
		return npc;
	}
	
	/**
	 * 根据 npc key 获得Npc实例拷贝
	 * @参数键
	 * @返回
	 */
	public static Npc selectNpcByKey(long npckey){
		
		Npc npc = getInstance().getNpcs().get(npckey);
		if(npc == null)
			return null;
		Npc copy = npc.copy();
		
		xbean.NpcInfo npcinfo =  xtable.Npcs.select(npckey);
		if(npcinfo == null)
			npcinfo = xbean.Pod.newNpcInfoData();
		
		copy.setNpcinfo(npcinfo);
		return copy;
	}
	
	/**
	 * 根据npckey获取npcid
	 * @参数键
	 * @return -1 没有找到该npc
	 */
	public static int getNpcIDByKey(long key){
		final Npc npc = selectNpcByKey(key);
		if (null == npc )
			return -1;
		else return npc.getNpcID();
	}

	/**
	 * 在某个指定的地图上随机生成npc
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcByMap(long npckey, int npcBaseId, String name,long sceneId,int dir,long time )
	{
		GCreateNPCByMap gCreateNpc = new GCreateNPCByMap();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		GsClient.sendToScene(gCreateNpc);
	}
	
	/**
	 * 在某个指定的地图上随机生成npc
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @param ownerId 大于0时 sceneid为mapid，通过mapid和ownerid确定场景
	 * @参数目录
	 * @param time 如果是限时NPC，填时间（毫秒），非限时NPC默认填0
	 */
	public static void createNpcByMap(long npckey, int npcBaseId, String name,int mapId, long ownerId,int dir,long time )
	{
		GCreateNPCByMap gCreateNpc = new GCreateNPCByMap();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = mapId;
		gCreateNpc.npc.ownerid = ownerId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.toufangareatype = MapUtil.TOUFANG_AREA;
		if (Transaction.current() != null)
			GsClient.pSendWhileCommit(gCreateNpc);
		else
			GsClient.sendToScene(gCreateNpc);
	}
	
	/**
	 * 在某个指定的地图上随机生成npc
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcByMapWhileCommit(long npckey, int npcBaseId, String name,long sceneId,int dir,long time,int toufangareatype)
	{
		GCreateNPCByMap gCreateNpc = new GCreateNPCByMap();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.toufangareatype = toufangareatype;
		if(Transaction.current()!= null)
			GsClient.pSendWhileCommit(gCreateNpc);
		else
			GsClient.sendToScene(gCreateNpc);
	}
	public static void createNpcByMapWhileCommit(long npckey, int npcBaseId, String name,long sceneId,int dir,long time )
	{
		createNpcByMapWhileCommit(npckey, npcBaseId, name, sceneId, dir, time,MapUtil.TOUFANG_AREA);
	}
	
	
	public static void createNpcByGridScale(long npckey, int npcBaseId, String name,long sceneId,int dir,int posx, int posy, int gridscale,long time ,int toufangarea)
	{
		GCreateNPCByGridScale gCreateNpc = new GCreateNPCByGridScale();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = posx;
		gCreateNpc.posy = posy;
		gCreateNpc.scale = gridscale;
		gCreateNpc.toufangarea = toufangarea;
		GsClient.sendToScene(gCreateNpc);
	}
	
	/**
	 * 在某个指定的地图上随机生成npc
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcByGridScaleWhileCommit(long npckey, int npcBaseId, String name,long sceneId,int dir,int posx, int posy, int gridscale,long time ,int toufangarea)
	{
		GCreateNPCByGridScale gCreateNpc = new GCreateNPCByGridScale();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = posx;
		gCreateNpc.posy = posy;
		gCreateNpc.scale = gridscale;
		gCreateNpc.toufangarea = toufangarea;
		if(Transaction.current()!= null)
			GsClient.pSendWhileCommit(gCreateNpc);
		else
			GsClient.sendToScene(gCreateNpc);
	}
	/**
	 * 在某个指定的地图上的某个区块随机生成npc
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcInRegionWhileCommit(long npckey, int npcBaseId, String name,long sceneId,int dir,int leftTopX, int leftTopY, int width,int height,long time )
	{
		GCreateNpcInRegion gCreateNpc = new GCreateNpcInRegion();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.lefttopx = leftTopX;
		gCreateNpc.lefttopy = leftTopY;
		gCreateNpc.width = width;
		gCreateNpc.height = height;
		if(Transaction.current()!= null)
			GsClient.pSendWhileCommit(gCreateNpc);
		else
			GsClient.sendToScene(gCreateNpc);
	}
	

	
	/**
	 * 在指定的地图上指定的坐标生成npc
	 * ！注意，因为坐标无法在逻辑模块判断是否有阻挡点/npc，所以该坐标只有逻辑十分确定可用时才行
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcByPos(long npckey, int npcBaseId, String name,long sceneId, int x, int y ,int dir, long time )
	{
		GCreateNPCByPos gCreateNpc = new GCreateNPCByPos();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = x;
		gCreateNpc.posy = y;
		GsClient.sendToScene(gCreateNpc);
	}
	
	/**
	 * 在指定的地图上指定的坐标生成npc
	 * ！注意，因为坐标无法在逻辑模块判断是否有阻挡点/npc，所以该坐标只有逻辑十分确定可用时才行
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数mapId
	 * @参数所有者ID
	 * @参数目录
	 */
	public static void createNpcByPos(long npckey, int npcBaseId, String name,long mapId, long ownerId, int x, int y ,int dir, long time )
	{
		GCreateNPCByPos gCreateNpc = new GCreateNPCByPos();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = mapId;
		gCreateNpc.npc.ownerid = ownerId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = x;
		gCreateNpc.posy = y;
		GsClient.sendToScene(gCreateNpc);
	}
	
	public static void createNpcWithRoleids(long npckey, int npcBaseId, String name,long sceneId, int x, int y ,int dir, long time, Set<Long> roleids){
		GCreateNPCWithRoleids gCreateNpc = new GCreateNPCWithRoleids();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = x;
		gCreateNpc.posy = y;
		gCreateNpc.roleids.addAll(roleids);
		GsClient.sendToScene(gCreateNpc);
	}
	
	/**
	 * 在指定的地图上指定的坐标生成npc,坐标是Postiton,不是GridPos
	 * ！注意，因为坐标无法在逻辑模块判断是否有阻挡点/npc，所以该坐标只有逻辑十分确定可用时才行
	 * @param npckey
	 * @param npcBaseId
	 * @参数名称
	 * @参数场景Id
	 * @参数目录
	 */
	public static void createNpcByPosWhileCommit(long npckey, int npcBaseId, String name,long sceneId, int x, int y ,int dir, long time )
	{
		GCreateNPCByPos gCreateNpc = new GCreateNPCByPos();
		gCreateNpc.npc.npckey = npckey;
		gCreateNpc.npc.npcbaseid = npcBaseId;
		gCreateNpc.npc.sceneid = sceneId;
		gCreateNpc.npc.name = name;
		gCreateNpc.npc.dir = dir;
		gCreateNpc.npc.time = time;
		gCreateNpc.posx = x;
		gCreateNpc.posy = y;
		if(Transaction.current()!= null)
			GsClient.pSendWhileCommit(gCreateNpc);
		else
			GsClient.sendToScene(gCreateNpc);
	}
	
	
	/**
	 * 从NPC的xdb表中删除npc，并用通用消息通知地图模块
	 * @param npckey
	 */
	public static void removeNpc(final long npckey)
	{
		String trace = fire.pb.util.Parser.convertfireStackTrace2String(Thread.currentThread().getStackTrace());
		if (Transaction.current() != null)
			new PRemoveNpcFromGS(npckey,trace).call();
		else
		{// 删除npc不一定是在procedure里面的
			new PRemoveNpcFromGS(npckey,trace).submit();
		}
	}
	/**
	 * 从NPC的xdb表中删除npc，并用通用消息通知地图模块
	 * @param npckey
	 */
	public static void premoveNpcWhileCommit(final long npckey)
	{
		String trace = fire.pb.util.Parser.convertfireStackTrace2String(Thread.currentThread().getStackTrace());
		if (Transaction.current() != null)
			new PRemoveNpcFromGS(npckey,trace).call();
		else
		{// 删除npc不一定是在procedure里面的
			new PRemoveNpcFromGS(npckey,trace).submit();
		}
	}
	
	/**
	 * 检查npc与人之间的距离是否可交互
	 * 可以在存储过程外使用
	 * @param npckey
	 * @参数角色ID
	 * @返回
	 */
	public static boolean checkDistance(long npckey, long roleid){
		Npc npc = SceneNpcManager.selectNpcByKey(npckey);
		Role role = RoleManager.getInstance().getRoleByID(roleid);
		if (npc == null || role == null){
			if(npc == null){
				logger.error("npc 距离校验出错" + "npc为null. npckey:"+npckey);
			}
			
			if(role == null){
				logger.error("npc 距离校验出错" + "role为null.roleid:"+roleid);
			}
			return false;
		}
		else{
			// 此处用了定义的交易距离的限制。策划的要求数据是一致的。
			if(role.checkDistance(npc, Sys.TRADE_DISTANCE)){
				return true;
			}else{
				logger.debug("此处用了定义的交易距离的限制。策划的要求数据是一致的.roleid:"+roleid);
				return false;
			}
		}
	}
}
