
package xbean;

public interface GiveFlowerRecord extends mkdb.Bean {
	public GiveFlowerRecord copy(); // 深拷贝
	public GiveFlowerRecord toData(); // 一个 Data 实例
	public GiveFlowerRecord toBean(); // 一个 Bean 实例
	public GiveFlowerRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GiveFlowerRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTriggertime(); // 
	public xbean.MarshalGiveFlowerRecord getMarshaldata(); // 

	public void setTriggertime(long _v_); // 
}
