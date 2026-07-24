
package xbean;

public interface ActivityCalendarStatus extends mkdb.Bean {
	public ActivityCalendarStatus copy(); // 深拷贝
	public ActivityCalendarStatus toData(); // 一个 Data 实例
	public ActivityCalendarStatus toBean(); // 一个 Bean 实例
	public ActivityCalendarStatus toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ActivityCalendarStatus toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getWeek(); // 该记录是今年的第几周的
	public java.util.Map<Integer, xbean.DayFinishTask> getDaystatus(); // 
	public java.util.Map<Integer, xbean.DayFinishTask> getDaystatusAsData(); // 

	public void setWeek(int _v_); // 该记录是今年的第几周的
}
