
package xbean;

public interface ClanWeekNum extends mkdb.Bean {
	public ClanWeekNum copy(); // 深拷贝
	public ClanWeekNum toData(); // 一个 Data 实例
	public ClanWeekNum toBean(); // 一个 Bean 实例
	public ClanWeekNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanWeekNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getWeeknum(); // 公会周更新记录周数

	public void setWeeknum(long _v_); // 公会周更新记录周数
}
