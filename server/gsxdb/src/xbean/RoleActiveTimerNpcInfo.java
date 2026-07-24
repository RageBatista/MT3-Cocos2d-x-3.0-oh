
package xbean;

public interface RoleActiveTimerNpcInfo extends mkdb.Bean {
	public RoleActiveTimerNpcInfo copy(); // 深拷贝
	public RoleActiveTimerNpcInfo toData(); // 一个 Data 实例
	public RoleActiveTimerNpcInfo toBean(); // 一个 Bean 实例
	public RoleActiveTimerNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleActiveTimerNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.RoleTimerNpcInfo> getActinfo(); // //key是活动id
	public java.util.Map<Integer, xbean.RoleTimerNpcInfo> getActinfoAsData(); // //key是活动id

}
