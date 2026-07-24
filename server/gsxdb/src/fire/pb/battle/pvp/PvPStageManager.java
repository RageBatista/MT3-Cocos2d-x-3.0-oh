package fire.pb.battle.pvp;

import java.util.HashMap;
import java.util.Map;

/**
 * PvP阶段管理
 * @作者XGM
 */
public class PvPStageManager {

	private final Map<EPvPStage, IPvPStage> manager = new HashMap<EPvPStage, IPvPStage>();

	/**
	 * 注册
	 * @参数e
	 * @参数我
	 */
	public void register(EPvPStage e, IPvPStage i) {
		manager.put(e, i);
	}

	/**
	 * 获取
	 * @参数e
	 * @返回
	 */
	public IPvPStage get(EPvPStage e) {
		return manager.get(e);
	}
}
