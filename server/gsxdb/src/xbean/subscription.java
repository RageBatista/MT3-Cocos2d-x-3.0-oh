
package xbean;

public interface subscription extends mkdb.Bean {
	public subscription copy(); // 深拷贝
	public subscription toData(); // 一个 Data 实例
	public subscription toBean(); // 一个 Bean 实例
	public subscription toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public subscription toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getExpiretime(); // 订阅过期时间
	public long getSubscribetime(); // 上次订阅开始时间

	public void setExpiretime(long _v_); // 订阅过期时间
	public void setSubscribetime(long _v_); // 上次订阅开始时间
}
