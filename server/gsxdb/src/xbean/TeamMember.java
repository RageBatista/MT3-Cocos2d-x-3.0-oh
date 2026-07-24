
package xbean;

public interface TeamMember extends mkdb.Bean {
	public TeamMember copy(); // 深拷贝
	public TeamMember toData(); // 一个 Data 实例
	public TeamMember toBean(); // 一个 Bean 实例
	public TeamMember toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TeamMember toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public int getState(); // 

	public void setRoleid(long _v_); // 
	public void setState(int _v_); // 
}
