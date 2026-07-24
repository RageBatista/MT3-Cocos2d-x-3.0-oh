
package xbean;

public interface User extends mkdb.Bean {
	public User copy(); // 深拷贝
	public User toData(); // 一个 Data 实例
	public User toBean(); // 一个 Bean 实例
	public User toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public User toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getPrevloginroleid(); // 上一次登录的角色
	public java.util.List<Long> getIdlist(); // 用户的角色列表 value是roleid
	public java.util.List<Long> getIdlistAsData(); // 用户的角色列表 value是roleid
	public long getCreatetime(); // 帐号第一次进入游戏的时间
	public int getIsfirst(); // 是否第一次登陆0第一次   1不是第一次

	public void setPrevloginroleid(long _v_); // 上一次登录的角色
	public void setCreatetime(long _v_); // 帐号第一次进入游戏的时间
	public void setIsfirst(int _v_); // 是否第一次登陆0第一次   1不是第一次
}
