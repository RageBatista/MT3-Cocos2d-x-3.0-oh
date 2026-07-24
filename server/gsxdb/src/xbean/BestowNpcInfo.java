
package xbean;

public interface BestowNpcInfo extends mkdb.Bean {
	public BestowNpcInfo copy(); // 深拷贝
	public BestowNpcInfo toData(); // 一个 Data 实例
	public BestowNpcInfo toBean(); // 一个 Bean 实例
	public BestowNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BestowNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 宝箱刷新的角色

	public void setRoleid(long _v_); // 宝箱刷新的角色
}
