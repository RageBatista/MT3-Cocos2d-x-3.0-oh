
package xbean;

public interface MarshalRoleLevelRecord extends mkdb.Bean {
	public MarshalRoleLevelRecord copy(); // 深拷贝
	public MarshalRoleLevelRecord toData(); // 一个 Data 实例
	public MarshalRoleLevelRecord toBean(); // 一个 Bean 实例
	public MarshalRoleLevelRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalRoleLevelRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id
	public String getRolename(); // 名字
	public com.locojoy.base.Octets getRolenameOctets(); // 名字
	public int getLevel(); // 等级
	public int getSchool(); // 职业id
	public int getShape(); // 新增：角色造型
	public int getRank(); // 排名
	public int getColor1(); // 颜色1
	public int getColor2(); // 颜色2
	public java.util.Map<Integer, Integer> getComponents(); // 装备部件
	public java.util.Map<Integer, Integer> getComponentsAsData(); // 装备部件

	public void setRoleid(long _v_); // 角色id
	public void setRolename(String _v_); // 名字
	public void setRolenameOctets(com.locojoy.base.Octets _v_); // 名字
	public void setLevel(int _v_); // 等级
	public void setSchool(int _v_); // 职业id
	public void setShape(int _v_); // 新增：角色造型
	public void setRank(int _v_); // 排名
	public void setColor1(int _v_); // 颜色1
	public void setColor2(int _v_); // 颜色2
}
