
package xbean;

public interface TeamInvite extends mkdb.Bean {
	public TeamInvite copy(); // 深拷贝
	public TeamInvite toData(); // 一个 Data 实例
	public TeamInvite toBean(); // 一个 Bean 实例
	public TeamInvite toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TeamInvite toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTeamid(); // 
	public long getRoleid(); // 
	public long getInvitetime(); // 

	public void setTeamid(long _v_); // 
	public void setRoleid(long _v_); // 
	public void setInvitetime(long _v_); // 
}
