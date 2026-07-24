package fire.pb.item.make;

import java.util.HashMap;
import java.util.Map;

import fire.log.Logger;
import fire.pb.item.SEquipAddattributelib;
import fire.pb.item.SEquipAddattributerandomlib;
import fire.pb.item.SEquipIteminfo;
import fire.pb.item.SEquipMakeInfo;
import fire.pb.main.ConfigManager;

public class ItemMakeUtil {
	
	static public final Logger logger = Logger.getLogger("ITEM");
	
	public static Map<Integer, SEquipIteminfo> EQUIPITEMINFO_CFGS = null;
	
	public static Map<Integer, SEquipAddattributelib> EQUIPADDATTR_CFGS = null;
	
	public static Map<Integer, SEquipAddattributerandomlib> EQUIPADDRANDOM_CFGS = null;
	
	public static Map<Integer, SEquipMakeInfo> EQUIPMAKEINFO_CFGS = null;

	
	
	
	public static Map<Integer, ZhuangBeiShuXing> effectConfigs;
	public static Map<Integer, FujiaShuXingXinXi> fujiaShuXingConfigs;
	
	public static void Init() throws Exception {
		logger.info("ItemMakeUtil.Init() 开始执行...");
		
		// 初始化静态字段（避免类加载时初始化导致的问题）
		effectConfigs = new HashMap<Integer, ZhuangBeiShuXing>();
		fujiaShuXingConfigs = new HashMap<Integer, FujiaShuXingXinXi>();
		
		// 检查 ConfigManager 是否已初始化
		ConfigManager configManager = ConfigManager.getInstance();
		if (configManager == null) {
			logger.error("ERROR: ConfigManager 未初始化，无法获取配置！");
			throw new Exception("ConfigManager 未初始化");
		}
		
		// 获取所有配置
		EQUIPITEMINFO_CFGS = configManager.getConf(SEquipIteminfo.class);
		EQUIPADDATTR_CFGS = configManager.getConf(SEquipAddattributelib.class);
		EQUIPADDRANDOM_CFGS = configManager.getConf(SEquipAddattributerandomlib.class);
		EQUIPMAKEINFO_CFGS = configManager.getConf(SEquipMakeInfo.class);
		
		// 验证配置是否加载成功
		if (EQUIPITEMINFO_CFGS == null || EQUIPITEMINFO_CFGS.isEmpty()) {
			logger.error("ERROR: SEquipIteminfo 配置为空或未加载");
			throw new Exception("SEquipIteminfo 配置为空或未加载");
		}
		if (EQUIPADDATTR_CFGS == null || EQUIPADDATTR_CFGS.isEmpty()) {
			logger.error("ERROR: SEquipAddattributelib 配置为空或未加载");
			throw new Exception("SEquipAddattributelib 配置为空或未加载");
		}
		if (EQUIPADDRANDOM_CFGS == null || EQUIPADDRANDOM_CFGS.isEmpty()) {
			logger.error("ERROR: SEquipAddattributerandomlib 配置为空或未加载");
			throw new Exception("SEquipAddattributerandomlib 配置为空或未加载");
		}
		if (EQUIPMAKEINFO_CFGS == null || EQUIPMAKEINFO_CFGS.isEmpty()) {
			logger.error("ERROR: SEquipMakeInfo 配置为空或未加载");
			throw new Exception("SEquipMakeInfo 配置为空或未加载");
		}
		
		logger.info("配置加载完成: EQUIPITEMINFO_CFGS=" + EQUIPITEMINFO_CFGS.size() +
				", EQUIPADDATTR_CFGS=" + EQUIPADDATTR_CFGS.size() +
				", EQUIPADDRANDOM_CFGS=" + EQUIPADDRANDOM_CFGS.size() +
				", EQUIPMAKEINFO_CFGS=" + EQUIPMAKEINFO_CFGS.size());
		
		// effectConfigs 已在 Init() 开始时初始化，无需 clear()
		int equipIteminfoSuccessCount = 0;
		int equipIteminfoFailCount = 0;
		for (SEquipIteminfo sequipIteminfo : EQUIPITEMINFO_CFGS.values())
		{
			try
			{
				ShuXing erandom = null;
				ZhuangBeiShuXing effectRmd = new ZhuangBeiShuXing();  //行
				
				int n = 0;
				int m = 0;
				
				if (sequipIteminfo.shuxing1name != null) {
					erandom = new ShuXing(sequipIteminfo.shuxing1name);
					n = 0;
					for (int i = 0; i < sequipIteminfo.shuxing1bodongduanmin.size(); i ++)
					{
						BoDongDuan bodongduan = new BoDongDuan(n, sequipIteminfo.shuxing1bodongquanzhong.get(i),
								sequipIteminfo.shuxing1bodongduanmin.get(i), sequipIteminfo.shuxing1bodongduanmax.get(i));
						
						erandom.PutBoDongDuan(n, bodongduan);
						n ++;
					}
					effectRmd.PutERandom(m, erandom);
					m ++;
				}
				
				if (sequipIteminfo.shuxing2name != null) {
					erandom = new ShuXing(sequipIteminfo.shuxing2name);
					n = 0;
					for (int i = 0; i < sequipIteminfo.shuxing2bodongduanmin.size(); i ++)
					{
						BoDongDuan bodongduan = new BoDongDuan(n, sequipIteminfo.shuxing2bodongquanzhong.get(i),
								sequipIteminfo.shuxing2bodongduanmin.get(i), sequipIteminfo.shuxing2bodongduanmax.get(i));
						
						erandom.PutBoDongDuan(n, bodongduan);
						n ++;
					}
					effectRmd.PutERandom(m, erandom);
					m ++;
				}

				if (sequipIteminfo.shuxing3name != null) {
					erandom = new ShuXing(sequipIteminfo.shuxing3name);
					n = 0;
					for (int i = 0; i < sequipIteminfo.shuxing3bodongduanmin.size(); i ++)
					{
						BoDongDuan bodongduan = new BoDongDuan(n, sequipIteminfo.shuxing3bodongquanzhong.get(i),
								sequipIteminfo.shuxing3bodongduanmin.get(i), sequipIteminfo.shuxing3bodongduanmax.get(i));
						
						erandom.PutBoDongDuan(n, bodongduan);
						n ++;
					}
					effectRmd.PutERandom(m, erandom);
					m ++;
				}
				
				effectConfigs.put(sequipIteminfo.id, effectRmd);
				equipIteminfoSuccessCount++;
			}
			catch (Exception e)
			{
				e.printStackTrace();
				logger.error(new StringBuffer().append("ERROR: Init SEquipIteminfo config fail, id=").append(sequipIteminfo.id).append(", ").append(e.toString()));
				equipIteminfoFailCount++;
			}
		}
		logger.info("SEquipIteminfo 配置处理完成: 成功=" + equipIteminfoSuccessCount + ", 失败=" + equipIteminfoFailCount);
		
		//处理附加属性
		// fujiaShuXingConfigs 已在 Init() 开始时初始化，无需 clear()
		int equipAddattrRandomSuccessCount = 0;
		int equipAddattrRandomFailCount = 0;
		for (SEquipAddattributerandomlib sequiaddr : EQUIPADDRANDOM_CFGS.values()) {
			try
			{
				FujiaShuXingXinXi fujia = new FujiaShuXingXinXi(); //附加属性
				for (int i = 0; i < sequiaddr.getAddattributer().size(); i ++) {
					int attrid = sequiaddr.getAddattributer().get(i);
					if (attrid > 0) {
						fujia.addtableId.add(attrid);
						fujia.addquanzhong.add(sequiaddr.getAddattributerquanzhong().get(i));
						
						SEquipAddattributelib addattr = EQUIPADDATTR_CFGS.get(attrid);
						if (addattr == null)
							continue;
						
						if (addattr.getAttributename() != null) {
							fujia.addname.add(addattr.getAttributename());
						}
					}
				}
				
				fujiaShuXingConfigs.put(sequiaddr.getId(), fujia);
				equipAddattrRandomSuccessCount++;
			}
			catch (Exception e)
			{
				e.printStackTrace();
				logger.error(new StringBuffer().append("ERROR: Init SEquipAddattributerandomlib config fail, id=").append(sequiaddr.getId()).append(", ").append(e.toString()));
				equipAddattrRandomFailCount++;
			}
		}
		logger.info("SEquipAddattributerandomlib 配置处理完成: 成功=" + equipAddattrRandomSuccessCount + ", 失败=" + equipAddattrRandomFailCount);
		
		logger.info("ItemMakeUtil.Init() 执行完成");
	}
}
