
package xbean;

public interface ProfessionLeaderInfo extends mkdb.Bean {
	public ProfessionLeaderInfo copy(); // 深拷贝
	public ProfessionLeaderInfo toData(); // 一个 Data 实例
	public ProfessionLeaderInfo toBean(); // 一个 Bean 实例
	public ProfessionLeaderInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ProfessionLeaderInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 职业领袖对应的role的id
	public int getRefreshtimes(); // 每天刷新职业领袖能力不超过5次
	public long getLastrefreshtime(); // 上次刷新的时间
	public java.util.List<xbean.Monster> getMonsterbean(); // 血,魔和其他攻击属性都从Monster中获取,其实本应不用vector,但生成的代码没有set function
	public java.util.List<xbean.Monster> getMonsterbeanAsData(); // 血,魔和其他攻击属性都从Monster中获取,其实本应不用vector,但生成的代码没有set function
	public java.util.Map<Integer, Integer> getShapecomponent(); // 
	public java.util.Map<Integer, Integer> getShapecomponentAsData(); // 

	public void setRoleid(long _v_); // 职业领袖对应的role的id
	public void setRefreshtimes(int _v_); // 每天刷新职业领袖能力不超过5次
	public void setLastrefreshtime(long _v_); // 上次刷新的时间
}
