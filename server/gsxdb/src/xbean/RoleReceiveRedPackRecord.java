
package xbean;

public interface RoleReceiveRedPackRecord extends mkdb.Bean {
	public RoleReceiveRedPackRecord copy(); // 深拷贝
	public RoleReceiveRedPackRecord toData(); // 一个 Data 实例
	public RoleReceiveRedPackRecord toBean(); // 一个 Bean 实例
	public RoleReceiveRedPackRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleReceiveRedPackRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getModeltype(); // 红包类型
	public long getSendroleid(); // 发送红包角色Id
	public String getRedpackid(); // 红包Id
	public com.locojoy.base.Octets getRedpackidOctets(); // 红包Id
	public long getReceivegold(); // 收红包金币数量
	public long getReceivefushi(); // 收红包符石数量
	public long getReceivetime(); // 领取时间

	public void setModeltype(int _v_); // 红包类型
	public void setSendroleid(long _v_); // 发送红包角色Id
	public void setRedpackid(String _v_); // 红包Id
	public void setRedpackidOctets(com.locojoy.base.Octets _v_); // 红包Id
	public void setReceivegold(long _v_); // 收红包金币数量
	public void setReceivefushi(long _v_); // 收红包符石数量
	public void setReceivetime(long _v_); // 领取时间
}
