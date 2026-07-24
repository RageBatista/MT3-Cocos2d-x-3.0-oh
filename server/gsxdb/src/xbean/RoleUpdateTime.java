
package xbean;

public interface RoleUpdateTime extends mkdb.Bean {
	public RoleUpdateTime copy(); // 深拷贝
	public RoleUpdateTime toData(); // 一个 Data 实例
	public RoleUpdateTime toBean(); // 一个 Bean 实例
	public RoleUpdateTime toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleUpdateTime toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getDateupdatetime(); // 每日更新时间
	public long getWeekupdatetime(); // 每周更新时间

	public void setDateupdatetime(long _v_); // 每日更新时间
	public void setWeekupdatetime(long _v_); // 每周更新时间
}
