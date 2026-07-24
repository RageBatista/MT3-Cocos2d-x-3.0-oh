package fire.pb.battle.pvp;

/**
 * PvP服务接口
 * @作者XGM
 */
public interface IPvPServiceHandle {

	/**
	 * 对服务的处理
	 * @参数角色Id
	 * @param参数
	 */
	void handle(final long roleId, int serviceId);
}