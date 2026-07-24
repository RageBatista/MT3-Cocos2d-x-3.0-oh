
package xbean;

public interface ReceFlowerRecord extends mkdb.Bean {
	public ReceFlowerRecord copy(); // 深拷贝
	public ReceFlowerRecord toData(); // 一个 Data 实例
	public ReceFlowerRecord toBean(); // 一个 Bean 实例
	public ReceFlowerRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ReceFlowerRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTriggertime(); // 
	public xbean.MarshalReceFlowerRecord getMarshaldata(); // 

	public void setTriggertime(long _v_); // 
}
