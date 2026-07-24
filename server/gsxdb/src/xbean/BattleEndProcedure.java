
package xbean;

public interface BattleEndProcedure extends mkdb.Bean {
	public BattleEndProcedure copy(); // 深拷贝
	public BattleEndProcedure toData(); // 一个 Data 实例
	public BattleEndProcedure toBean(); // 一个 Bean 实例
	public BattleEndProcedure toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BattleEndProcedure toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getFighterid(); // 战斗者ID，（现在应该是只有角色，将来还可能会有宠物）
	public mkdb.Procedure getEndprocedure(); // 战斗者出战斗时执行的Procedure

	public void setFighterid(int _v_); // 战斗者ID，（现在应该是只有角色，将来还可能会有宠物）
	public void setEndprocedure(mkdb.Procedure _v_); // 战斗者出战斗时执行的Procedure
}
