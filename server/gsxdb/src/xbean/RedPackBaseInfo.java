
package xbean;

public interface RedPackBaseInfo extends mkdb.Bean {
	public RedPackBaseInfo copy(); // 深拷贝
	public RedPackBaseInfo toData(); // 一个 Data 实例
	public RedPackBaseInfo toBean(); // 一个 Bean 实例
	public RedPackBaseInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackBaseInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色Id
	public String getRedpackid(); // 红包Id
	public com.locojoy.base.Octets getRedpackidOctets(); // 红包Id
	public long getSendtime(); // 发送时间

	public void setRoleid(long _v_); // 角色Id
	public void setRedpackid(String _v_); // 红包Id
	public void setRedpackidOctets(com.locojoy.base.Octets _v_); // 红包Id
	public void setSendtime(long _v_); // 发送时间
}
