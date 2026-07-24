
package xbean;

public interface ServerRoles extends mkdb.Bean {
	public ServerRoles copy(); // 深拷贝
	public ServerRoles toData(); // 一个 Data 实例
	public ServerRoles toBean(); // 一个 Bean 实例
	public ServerRoles toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ServerRoles toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRolenum(); // 
	public long getCreatetime(); // 

	public void setRolenum(int _v_); // 
	public void setCreatetime(long _v_); // 
}
