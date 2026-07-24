
package xbean;

public interface EClanFightStatistics extends mkdb.Bean {
	public EClanFightStatistics copy(); // 深拷贝
	public EClanFightStatistics toData(); // 一个 Data 实例
	public EClanFightStatistics toBean(); // 一个 Bean 实例
	public EClanFightStatistics toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EClanFightStatistics toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getAct(); // 行动力，作者 changhao
	public int getScore(); // 积分，作者 changhao
	public long getEntertime(); // 进入战场时间，作者 changhao
	public int getWinneritemnum(); // 获取胜利宝箱的数量，作者 changhao
	public int getClancelebrateitemnum(); // 获取公会庆祝宝箱的数量，作者 changhao
	public int getWinnum(); // 连续胜利的常数，作者 changhao
	public long getLastcbattlefieldrankliststamp(); // 上次请求战场积分时间戳，作者 changhao
	public long getLastlosestamp(); // 上次战败时间戳，作者 changhao

	public void setAct(int _v_); // 行动力，作者 changhao
	public void setScore(int _v_); // 积分，作者 changhao
	public void setEntertime(long _v_); // 进入战场时间，作者 changhao
	public void setWinneritemnum(int _v_); // 获取胜利宝箱的数量，作者 changhao
	public void setClancelebrateitemnum(int _v_); // 获取公会庆祝宝箱的数量，作者 changhao
	public void setWinnum(int _v_); // 连续胜利的常数，作者 changhao
	public void setLastcbattlefieldrankliststamp(long _v_); // 上次请求战场积分时间戳，作者 changhao
	public void setLastlosestamp(long _v_); // 上次战败时间戳，作者 changhao
}
