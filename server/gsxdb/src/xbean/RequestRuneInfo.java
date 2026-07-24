
package xbean;

public interface RequestRuneInfo extends mkdb.Bean {
	public RequestRuneInfo copy(); // 深拷贝
	public RequestRuneInfo toData(); // 一个 Data 实例
	public RequestRuneInfo toBean(); // 一个 Bean 实例
	public RequestRuneInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RequestRuneInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 请求角色roleid
	public long getTargetroleid(); // 目标roleid
	public int getActiontype(); // 动作类型  0 请求符文    1捐献符文
	public long getRequesttime(); // 请求时间
	public int getItemid(); // 物品id
	public int getItemlevel(); // 物品等级

	public void setRoleid(long _v_); // 请求角色roleid
	public void setTargetroleid(long _v_); // 目标roleid
	public void setActiontype(int _v_); // 动作类型  0 请求符文    1捐献符文
	public void setRequesttime(long _v_); // 请求时间
	public void setItemid(int _v_); // 物品id
	public void setItemlevel(int _v_); // 物品等级
}
