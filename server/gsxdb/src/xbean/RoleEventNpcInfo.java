
package xbean;

public interface RoleEventNpcInfo extends mkdb.Bean {
	public RoleEventNpcInfo copy(); // 深拷贝
	public RoleEventNpcInfo toData(); // 一个 Data 实例
	public RoleEventNpcInfo toBean(); // 一个 Bean 实例
	public RoleEventNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleEventNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getAwardtimes(); // //领取奖励次数
	public long getLastawardtime(); // //上次领取奖励时间

	public void setAwardtimes(int _v_); // //领取奖励次数
	public void setLastawardtime(long _v_); // //上次领取奖励时间
}
