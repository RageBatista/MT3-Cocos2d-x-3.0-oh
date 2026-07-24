
package xbean;

public interface EventInfo extends mkdb.Bean {
	public EventInfo copy(); // 深拷贝
	public EventInfo toData(); // 一个 Data 实例
	public EventInfo toBean(); // 一个 Bean 实例
	public EventInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EventInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public fire.pb.WorldEventTab.CrontabTask getEvent(); // 

	public void setEvent(fire.pb.WorldEventTab.CrontabTask _v_); // 
}
