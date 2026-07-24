
package xbean;

public interface RedPackRecord extends mkdb.Bean {
	public RedPackRecord copy(); // 深拷贝
	public RedPackRecord toData(); // 一个 Data 实例
	public RedPackRecord toBean(); // 一个 Bean 实例
	public RedPackRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTriggertime(); // 
	public xbean.MarshalRedPackRecord getMarshaldata(); // 

	public void setTriggertime(long _v_); // 
}
