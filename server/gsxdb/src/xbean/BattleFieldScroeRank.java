
package xbean;

public interface BattleFieldScroeRank extends mkdb.Bean {
	public BattleFieldScroeRank copy(); // 深拷贝
	public BattleFieldScroeRank toData(); // 一个 Data 实例
	public BattleFieldScroeRank toBean(); // 一个 Bean 实例
	public BattleFieldScroeRank toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BattleFieldScroeRank toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // id，作者 changhao
	public int getScroe(); // 积分，作者 changhao

	public void setRoleid(long _v_); // id，作者 changhao
	public void setScroe(int _v_); // 积分，作者 changhao
}
