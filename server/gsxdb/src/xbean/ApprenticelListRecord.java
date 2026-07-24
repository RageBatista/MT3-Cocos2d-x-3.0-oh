
package xbean;

public interface ApprenticelListRecord extends mkdb.Bean {
	public ApprenticelListRecord copy(); // 深拷贝
	public ApprenticelListRecord toData(); // 一个 Data 实例
	public ApprenticelListRecord toBean(); // 一个 Bean 实例
	public ApprenticelListRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ApprenticelListRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 达到这个数量的时间
	public xbean.MarshalApprenticeRecord getMarshaldata(); // 

	public void setTime(long _v_); // 达到这个数量的时间
}
