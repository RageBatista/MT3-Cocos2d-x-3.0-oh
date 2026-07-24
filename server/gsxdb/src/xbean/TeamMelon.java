
package xbean;

public interface TeamMelon extends mkdb.Bean {
	public TeamMelon copy(); // 深拷贝
	public TeamMelon toData(); // 一个 Data 实例
	public TeamMelon toBean(); // 一个 Bean 实例
	public TeamMelon toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TeamMelon toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemid(); // 道具表id，作者 changhao
	public int getItemnum(); // 道具数量，作者 changha
	public xbean.Item getItemdata(); // 道具数据，作者 changhao
	public int getAwardid(); // 奖励表id
	public java.util.Map<Long, Integer> getMelonroleids(); // 分赃人员(roll点决定)，作者 changhao
	public java.util.Map<Long, Integer> getMelonroleidsAsData(); // 分赃人员(roll点决定)，作者 changhao
	public java.util.Map<Long, Integer> getOpmelonroleids(); // 已经操作的分赃人员，作者 changhao
	public java.util.Map<Long, Integer> getOpmelonroleidsAsData(); // 已经操作的分赃人员，作者 changhao
	public int getMaxrollpoint(); // 最大ROLL点，作者 changhao
	public int getOpnum(); // 已经ROLL点的人员数量，作者 changhao
	public long getBattleid(); // 战斗ID，作者 changhao
	public int getBattleresult(); // 战斗结果，作者 changhao

	public void setItemid(int _v_); // 道具表id，作者 changhao
	public void setItemnum(int _v_); // 道具数量，作者 changha
	public void setAwardid(int _v_); // 奖励表id
	public void setMaxrollpoint(int _v_); // 最大ROLL点，作者 changhao
	public void setOpnum(int _v_); // 已经ROLL点的人员数量，作者 changhao
	public void setBattleid(long _v_); // 战斗ID，作者 changhao
	public void setBattleresult(int _v_); // 战斗结果，作者 changhao
}
