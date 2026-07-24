
package xbean;

public interface ModifyNameRole extends mkdb.Bean {
	public ModifyNameRole copy(); // 深拷贝
	public ModifyNameRole toData(); // 一个 Data 实例
	public ModifyNameRole toBean(); // 一个 Bean 实例
	public ModifyNameRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ModifyNameRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getLastbuytime(); // 上次购买的时间
	public long getLastmodtime(); // 上次改名的时间
	public int getBuycount(); // 记录已经购买的次数
	public int getModcount(); // 记录已经修改名字的次数

	public void setLastbuytime(long _v_); // 上次购买的时间
	public void setLastmodtime(long _v_); // 上次改名的时间
	public void setBuycount(int _v_); // 记录已经购买的次数
	public void setModcount(int _v_); // 记录已经修改名字的次数
}
