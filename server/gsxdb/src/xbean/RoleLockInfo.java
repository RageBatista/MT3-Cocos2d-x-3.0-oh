
package xbean;

public interface RoleLockInfo extends mkdb.Bean {
	public RoleLockInfo copy(); // 深拷贝
	public RoleLockInfo toData(); // 一个 Data 实例
	public RoleLockInfo toBean(); // 一个 Bean 实例
	public RoleLockInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleLockInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getPassword(); // 安全锁密码,为空表示没有设置安全锁
	public com.locojoy.base.Octets getPasswordOctets(); // 安全锁密码,为空表示没有设置安全锁
	public long getUnlocktime(); // 开始解锁的时间,为0表示没解锁
	public long getForceunlocktime(); // 开始强行解锁的时间,为0表示没有申请强制解锁
	public int getErrortimes(); // 连续输错密码的次数
	public long getFullerrortime(); // 连续输错密码达上限的时间

	public void setPassword(String _v_); // 安全锁密码,为空表示没有设置安全锁
	public void setPasswordOctets(com.locojoy.base.Octets _v_); // 安全锁密码,为空表示没有设置安全锁
	public void setUnlocktime(long _v_); // 开始解锁的时间,为0表示没解锁
	public void setForceunlocktime(long _v_); // 开始强行解锁的时间,为0表示没有申请强制解锁
	public void setErrortimes(int _v_); // 连续输错密码的次数
	public void setFullerrortime(long _v_); // 连续输错密码达上限的时间
}
