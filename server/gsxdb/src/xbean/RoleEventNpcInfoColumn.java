
package xbean;

public interface RoleEventNpcInfoColumn extends mkdb.Bean {
	public RoleEventNpcInfoColumn copy(); // 深拷贝
	public RoleEventNpcInfoColumn toData(); // 一个 Data 实例
	public RoleEventNpcInfoColumn toBean(); // 一个 Bean 实例
	public RoleEventNpcInfoColumn toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleEventNpcInfoColumn toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.RoleEventNpcInfo> getEventinfo(); // //key是活动id
	public java.util.Map<Integer, xbean.RoleEventNpcInfo> getEventinfoAsData(); // //key是活动id

}
