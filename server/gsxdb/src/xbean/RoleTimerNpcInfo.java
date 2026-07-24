
package xbean;

public interface RoleTimerNpcInfo extends mkdb.Bean {
	public RoleTimerNpcInfo copy(); // 深拷贝
	public RoleTimerNpcInfo toData(); // 一个 Data 实例
	public RoleTimerNpcInfo toBean(); // 一个 Bean 实例
	public RoleTimerNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleTimerNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getAwardtimes(); // //领取奖励次数
	public long getLastawardtime(); // //上次领取奖励时间

	public void setAwardtimes(int _v_); // //领取奖励次数
	public void setLastawardtime(long _v_); // //上次领取奖励时间
}
