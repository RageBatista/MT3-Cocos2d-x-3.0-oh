
package xbean;

public interface ServiceSet extends mkdb.Bean {
	public ServiceSet copy(); // 深拷贝
	public ServiceSet toData(); // 一个 Data 实例
	public ServiceSet toBean(); // 一个 Bean 实例
	public ServiceSet toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ServiceSet toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBindtelagain(); // 重新绑定手机的次数
	public long getBindtelagaintime(); // 重新绑定手机的时间

	public void setBindtelagain(int _v_); // 重新绑定手机的次数
	public void setBindtelagaintime(long _v_); // 重新绑定手机的时间
}
