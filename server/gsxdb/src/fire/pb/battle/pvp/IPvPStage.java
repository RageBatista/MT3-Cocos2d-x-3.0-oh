package fire.pb.battle.pvp;

/**
 * PvP阶段接口定义
 * @作者XGM
 */
public interface IPvPStage {

	/**
	 * 获得当前阶段
	 * @返回
	 */
	public EPvPStage getStage();

	/**
	 * 进入阶段
	 */
	public void onEnter(PvPControl c);

	/**
	 * 离开阶段
	 */
	public void onLeave(PvPControl c);

	/**
	 * 心跳
	 * @参数c
	 */
	public default void onTick(PvPControl c) {
		
	}

	/**
	 * 申请进入场景
	 * @参数角色Id
	 * @param goto类型
	 */
	public default boolean onApplyEnter(PvPControl c, final long roleId, int gotoType) {
		return false;
	}

	/**
	 * 申请离开场景
	 * @参数角色Id
	 */
	public default void onApplyLeave(PvPControl c, final long roleId) {
		
	}

	/**
	 * 领取奖励
	 * @参数c
	 * @参数角色Id
	 * @参数框类型
	 */
	public default boolean onGetAward(PvPControl c, final long roleId, final int boxType) {
		return c.doGetAward(roleId, boxType);
	}
}
