
package xbean;

public interface TriggerRole extends mkdb.Bean {
	public TriggerRole copy(); // 深拷贝
	public TriggerRole toData(); // 一个 Data 实例
	public TriggerRole toBean(); // 一个 Bean 实例
	public TriggerRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TriggerRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getTriggeredids(); // 
	public java.util.List<Integer> getTriggeredidsAsData(); // 

}
