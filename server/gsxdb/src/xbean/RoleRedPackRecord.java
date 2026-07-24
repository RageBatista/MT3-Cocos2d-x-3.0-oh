
package xbean;

public interface RoleRedPackRecord extends mkdb.Bean {
	public RoleRedPackRecord copy(); // 深拷贝
	public RoleRedPackRecord toData(); // 一个 Data 实例
	public RoleRedPackRecord toBean(); // 一个 Bean 实例
	public RoleRedPackRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleRedPackRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getSendnum(); // 发红包数量
	public long getSendgold(); // 发红包金币数量
	public long getSendfushi(); // 发红包符石数量
	public long getReceivenum(); // 收红包数量
	public long getReceivegold(); // 收红包金币数量
	public long getReceivefushi(); // 收红包符石数量

	public void setSendnum(long _v_); // 发红包数量
	public void setSendgold(long _v_); // 发红包金币数量
	public void setSendfushi(long _v_); // 发红包符石数量
	public void setReceivenum(long _v_); // 收红包数量
	public void setReceivegold(long _v_); // 收红包金币数量
	public void setReceivefushi(long _v_); // 收红包符石数量
}
