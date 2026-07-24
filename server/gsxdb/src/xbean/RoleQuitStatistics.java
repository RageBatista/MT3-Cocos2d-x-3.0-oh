
package xbean;

public interface RoleQuitStatistics extends mkdb.Bean {
	public RoleQuitStatistics copy(); // 深拷贝
	public RoleQuitStatistics toData(); // 一个 Data 实例
	public RoleQuitStatistics toBean(); // 一个 Bean 实例
	public RoleQuitStatistics toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleQuitStatistics toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getMoney(); // 
	public int getExp(); // 
	public java.util.Map<Integer, Long> getCurrency(); // 
	public java.util.Map<Integer, Long> getCurrencyAsData(); // 
	public long getLastcountdate(); // 最近统计钱,储备金,经验的时间
	public int getLastrewardidx(); // 上次领取奖励序号
	public long getRewarddate(); // 上次领取上线奖励

	public void setMoney(long _v_); // 
	public void setExp(int _v_); // 
	public void setLastcountdate(long _v_); // 最近统计钱,储备金,经验的时间
	public void setLastrewardidx(int _v_); // 上次领取奖励序号
	public void setRewarddate(long _v_); // 上次领取上线奖励
}
