
package xbean;

public interface RedPackRoleHisInfo extends mkdb.Bean {
	public RedPackRoleHisInfo copy(); // 深拷贝
	public RedPackRoleHisInfo toData(); // 一个 Data 实例
	public RedPackRoleHisInfo toBean(); // 一个 Bean 实例
	public RedPackRoleHisInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackRoleHisInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色Id
	public int getRedpackmoney(); // 红包金额
	public long getReceivetime(); // 领取时间

	public void setRoleid(long _v_); // 角色Id
	public void setRedpackmoney(int _v_); // 红包金额
	public void setReceivetime(long _v_); // 领取时间
}
