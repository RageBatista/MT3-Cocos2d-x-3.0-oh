
package xbean;

public interface DailyInfo extends mkdb.Bean {
	public DailyInfo copy(); // 深拷贝
	public DailyInfo toData(); // 一个 Data 实例
	public DailyInfo toBean(); // 一个 Bean 实例
	public DailyInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DailyInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getPaynum(); // 每日数量
	public long getTime(); // 每日数量
	public java.util.Map<Integer, Long> getDayrewardmap(); // 
	public java.util.Map<Integer, Long> getDayrewardmapAsData(); // 

	public void setPaynum(long _v_); // 每日数量
	public void setTime(long _v_); // 每日数量
}
