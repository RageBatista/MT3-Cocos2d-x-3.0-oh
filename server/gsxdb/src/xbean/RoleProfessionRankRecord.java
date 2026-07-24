
package xbean;

public interface RoleProfessionRankRecord extends mkdb.Bean {
	public RoleProfessionRankRecord copy(); // 深拷贝
	public RoleProfessionRankRecord toData(); // 一个 Data 实例
	public RoleProfessionRankRecord toBean(); // 一个 Bean 实例
	public RoleProfessionRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleProfessionRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRank(); // 排名
	public long getRoleid(); // 人物ID
	public String getRolename(); // 人物名称
	public com.locojoy.base.Octets getRolenameOctets(); // 人物名称
	public int getSchool(); // 职业
	public int getLevel(); // 等级
	public int getScore(); // 总评分
	public String getClanname(); // 帮会，作者 changhao
	public com.locojoy.base.Octets getClannameOctets(); // 帮会，作者 changhao
	public long getTriggertime(); // 触发时间，作者 changhao
	public int getShape(); // 角色造型
	public int getColor1(); // 颜色1
	public int getColor2(); // 颜色2
	public java.util.Map<Integer, Integer> getComponents(); // 装备部件
	public java.util.Map<Integer, Integer> getComponentsAsData(); // 装备部件

	public void setRank(int _v_); // 排名
	public void setRoleid(long _v_); // 人物ID
	public void setRolename(String _v_); // 人物名称
	public void setRolenameOctets(com.locojoy.base.Octets _v_); // 人物名称
	public void setSchool(int _v_); // 职业
	public void setLevel(int _v_); // 等级
	public void setScore(int _v_); // 总评分
	public void setClanname(String _v_); // 帮会，作者 changhao
	public void setClannameOctets(com.locojoy.base.Octets _v_); // 帮会，作者 changhao
	public void setTriggertime(long _v_); // 触发时间，作者 changhao
	public void setShape(int _v_); // 角色造型
	public void setColor1(int _v_); // 颜色1
	public void setColor2(int _v_); // 颜色2
}
