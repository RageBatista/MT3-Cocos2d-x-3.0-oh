
package xbean;

public interface TradingLock extends mkdb.Bean {
	public TradingLock copy(); // 深拷贝
	public TradingLock toData(); // 一个 Data 实例
	public TradingLock toBean(); // 一个 Bean 实例
	public TradingLock toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TradingLock toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTradingid(); // 交易ID
	public long getRoleid(); // 角色ID
	public int getItemid(); // 锁定的道具ID
	public int getItemkey(); // 锁定的道具在背包中的key
	public long getPetid(); // 锁定的宠物ID（如果是宠物交易）
	public long getLocktime(); // 锁定时间
	public int getLocktype(); // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易

	public void setTradingid(long _v_); // 交易ID
	public void setRoleid(long _v_); // 角色ID
	public void setItemid(int _v_); // 锁定的道具ID
	public void setItemkey(int _v_); // 锁定的道具在背包中的key
	public void setPetid(long _v_); // 锁定的宠物ID（如果是宠物交易）
	public void setLocktime(long _v_); // 锁定时间
	public void setLocktype(int _v_); // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
}
