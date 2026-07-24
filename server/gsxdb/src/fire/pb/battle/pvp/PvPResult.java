package fire.pb.battle.pvp;

/**
 * PvP某些复杂的返回结果
 * @作者XGM
 */
public abstract class PvPResult {

	// 结果
	protected final int result;

	/**
	 * 构造
	 * @参数结果
	 */
	public PvPResult(int result) {
		this.result = result;
	}

	/**
	 * 获取结果
	 * @返回
	 */
	public int get() {
		return result;
	}

	/**
	 * 处理
	 * @返回
	 */
	public abstract int handle();
}
