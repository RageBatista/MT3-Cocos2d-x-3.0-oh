
package xbean;

public interface MasterRankRecord extends mkdb.Bean {
	public MasterRankRecord copy(); // 深拷贝
	public MasterRankRecord toData(); // 一个 Data 实例
	public MasterRankRecord toBean(); // 一个 Bean 实例
	public MasterRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MasterRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 人物ID
	public String getRolename(); // 人物名称
	public com.locojoy.base.Octets getRolenameOctets(); // 人物名称
	public long getShidezhi(); // 师德值

	public void setRoleid(long _v_); // 人物ID
	public void setRolename(String _v_); // 人物名称
	public void setRolenameOctets(com.locojoy.base.Octets _v_); // 人物名称
	public void setShidezhi(long _v_); // 师德值
}
