
package xbean;

public interface BattleAI extends mkdb.Bean {
	public BattleAI copy(); // 深拷贝
	public BattleAI toData(); // 一个 Data 实例
	public BattleAI toBean(); // 一个 Bean 实例
	public BattleAI toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BattleAI toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 
	public int getCount(); // 成功执行的次数
	public int getEnableround(); // 启用时的回合数

	public void setId(int _v_); // 
	public void setCount(int _v_); // 成功执行的次数
	public void setEnableround(int _v_); // 启用时的回合数
}
