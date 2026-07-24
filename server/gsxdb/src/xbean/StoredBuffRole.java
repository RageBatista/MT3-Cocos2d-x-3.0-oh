
package xbean;

public interface StoredBuffRole extends mkdb.Bean {
	public StoredBuffRole copy(); // 深拷贝
	public StoredBuffRole toData(); // 一个 Data 实例
	public StoredBuffRole toBean(); // 一个 Bean 实例
	public StoredBuffRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public StoredBuffRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.Buff> getBuffs(); // 
	public java.util.Map<Integer, xbean.Buff> getBuffsAsData(); // 

}
