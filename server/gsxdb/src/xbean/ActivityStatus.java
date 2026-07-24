
package xbean;

public interface ActivityStatus extends mkdb.Bean {
	public ActivityStatus copy(); // 深拷贝
	public ActivityStatus toData(); // 一个 Data 实例
	public ActivityStatus toBean(); // 一个 Bean 实例
	public ActivityStatus toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ActivityStatus toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 活动的id
	public int getBaseid(); // 活动的baseid
	public long getInistarttime(); // 活动预计的开始的时间(填在表里的时间)
	public long getIniendtime(); // 活动预计的结束的时间(填在表里的时间)
	public long getLaststarttime(); // 最近开始的时间
	public long getLastendtime(); // 最近结束的时间
	public long getCosttime(); // 活动已经过去了多少时间

	public void setId(int _v_); // 活动的id
	public void setBaseid(int _v_); // 活动的baseid
	public void setInistarttime(long _v_); // 活动预计的开始的时间(填在表里的时间)
	public void setIniendtime(long _v_); // 活动预计的结束的时间(填在表里的时间)
	public void setLaststarttime(long _v_); // 最近开始的时间
	public void setLastendtime(long _v_); // 最近结束的时间
	public void setCosttime(long _v_); // 活动已经过去了多少时间
}
