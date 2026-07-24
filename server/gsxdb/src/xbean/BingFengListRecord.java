
package xbean;

public interface BingFengListRecord extends mkdb.Bean {
	public BingFengListRecord copy(); // 深拷贝
	public BingFengListRecord toData(); // 一个 Data 实例
	public BingFengListRecord toBean(); // 一个 Bean 实例
	public BingFengListRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengListRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 达到这个数量的时间
	public xbean.MarshalBingFengRecord getMarshaldata(); // 

	public void setTime(long _v_); // 达到这个数量的时间
}
