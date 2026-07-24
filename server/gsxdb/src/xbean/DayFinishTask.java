
package xbean;

public interface DayFinishTask extends mkdb.Bean {
	public DayFinishTask copy(); // 深拷贝
	public DayFinishTask toData(); // 一个 Data 实例
	public DayFinishTask toBean(); // 一个 Bean 实例
	public DayFinishTask toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DayFinishTask toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getTasklist(); // 
	public java.util.List<Integer> getTasklistAsData(); // 

}
