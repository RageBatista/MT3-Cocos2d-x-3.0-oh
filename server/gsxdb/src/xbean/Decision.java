
package xbean;

public interface Decision extends mkdb.Bean {
	public Decision copy(); // 深拷贝
	public Decision toData(); // 一个 Data 实例
	public Decision toBean(); // 一个 Bean 实例
	public Decision toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Decision toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getOperatetype(); // 操作类型
	public int getOperator(); // 操作方的战斗单位索引
	public int getAim(); // 目标的战斗单位索引
	public int getOperateid(); // 操作数，如使用物品的物品ID
	public boolean getIsauto(); // 操作是否是自动

	public void setOperatetype(int _v_); // 操作类型
	public void setOperator(int _v_); // 操作方的战斗单位索引
	public void setAim(int _v_); // 目标的战斗单位索引
	public void setOperateid(int _v_); // 操作数，如使用物品的物品ID
	public void setIsauto(boolean _v_); // 操作是否是自动
}
