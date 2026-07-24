
package xbean;

public interface RoleRankRecord extends mkdb.Bean {
	public RoleRankRecord copy(); // 深拷贝
	public RoleRankRecord toData(); // 一个 Data 实例
	public RoleRankRecord toBean(); // 一个 Bean 实例
	public RoleRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRank(); // 排名，作者 changhao
	public long getRoleid(); // 人物ID，作者 changhao
	public String getRolename(); // 人物名称，作者 changhao
	public com.locojoy.base.Octets getRolenameOctets(); // 人物名称，作者 changhao
	public int getSchool(); // 职业，作者 changhao
	public int getLevel(); // 等级，作者 changhao
	public int getScore(); // 人物评分，作者 changhao
	public long getTriggertime(); // 触发时间，作者 changhao
	public int getShape(); // 角色造型
	public int getColor1(); // 颜色1
	public int getColor2(); // 颜色2
	public java.util.Map<Integer, Integer> getComponents(); // 装备部件
	public java.util.Map<Integer, Integer> getComponentsAsData(); // 装备部件

	public void setRank(int _v_); // 排名，作者 changhao
	public void setRoleid(long _v_); // 人物ID，作者 changhao
	public void setRolename(String _v_); // 人物名称，作者 changhao
	public void setRolenameOctets(com.locojoy.base.Octets _v_); // 人物名称，作者 changhao
	public void setSchool(int _v_); // 职业，作者 changhao
	public void setLevel(int _v_); // 等级，作者 changhao
	public void setScore(int _v_); // 人物评分，作者 changhao
	public void setTriggertime(long _v_); // 触发时间，作者 changhao
	public void setShape(int _v_); // 角色造型
	public void setColor1(int _v_); // 颜色1
	public void setColor2(int _v_); // 颜色2
}
