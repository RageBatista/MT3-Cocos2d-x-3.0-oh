
package xbean;

public interface PvP3RaceRole extends mkdb.Bean {
	public PvP3RaceRole copy(); // 深拷贝
	public PvP3RaceRole toData(); // 一个 Data 实例
	public PvP3RaceRole toBean(); // 一个 Bean 实例
	public PvP3RaceRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP3RaceRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public String getName(); // 
	public com.locojoy.base.Octets getNameOctets(); // 
	public int getScore(); // 积分

	public void setRoleid(long _v_); // 
	public void setName(String _v_); // 
	public void setNameOctets(com.locojoy.base.Octets _v_); // 
	public void setScore(int _v_); // 积分
}
