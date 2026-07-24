
package xbean;

public interface PvP3ScoreRecord extends mkdb.Bean {
	public PvP3ScoreRecord copy(); // 深拷贝
	public PvP3ScoreRecord toData(); // 一个 Data 实例
	public PvP3ScoreRecord toBean(); // 一个 Bean 实例
	public PvP3ScoreRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP3ScoreRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id
	public String getRolename(); // 角色名字
	public com.locojoy.base.Octets getRolenameOctets(); // 角色名字
	public int getScore(); // 积分

	public void setRoleid(long _v_); // 角色id
	public void setRolename(String _v_); // 角色名字
	public void setRolenameOctets(com.locojoy.base.Octets _v_); // 角色名字
	public void setScore(int _v_); // 积分
}
