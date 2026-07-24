
package xbean;

public interface RoleApplyClan extends mkdb.Bean {
	public RoleApplyClan copy(); // 深拷贝
	public RoleApplyClan toData(); // 一个 Data 实例
	public RoleApplyClan toBean(); // 一个 Bean 实例
	public RoleApplyClan toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleApplyClan toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getClankey(); // 公会key
	public int getState(); // 申请状态
	public long getApplytiem(); // 申请时间

	public void setClankey(long _v_); // 公会key
	public void setState(int _v_); // 申请状态
	public void setApplytiem(long _v_); // 申请时间
}
