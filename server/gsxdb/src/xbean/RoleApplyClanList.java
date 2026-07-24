
package xbean;

public interface RoleApplyClanList extends mkdb.Bean {
	public RoleApplyClanList copy(); // 深拷贝
	public RoleApplyClanList toData(); // 一个 Data 实例
	public RoleApplyClanList toBean(); // 一个 Bean 实例
	public RoleApplyClanList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleApplyClanList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getOnekeylasttime(); // 上次一键申请时间
	public java.util.Map<Long, xbean.RoleApplyClan> getOnekeyapplymap(); // 
	public java.util.Map<Long, xbean.RoleApplyClan> getOnekeyapplymapAsData(); // 
	public java.util.Map<Long, xbean.RoleApplyClan> getApplymap(); // 
	public java.util.Map<Long, xbean.RoleApplyClan> getApplymapAsData(); // 

	public void setOnekeylasttime(long _v_); // 上次一键申请时间
}
