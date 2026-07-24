
package xbean;

public interface BattleFlags extends mkdb.Bean {
	public BattleFlags copy(); // 深拷贝
	public BattleFlags toData(); // 一个 Data 实例
	public BattleFlags toBean(); // 一个 Bean 实例
	public BattleFlags toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BattleFlags toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<String> getFriendflag(); // 
	public java.util.List<String> getFriendflagAsData(); // 
	public java.util.List<String> getEnemyflag(); // 
	public java.util.List<String> getEnemyflagAsData(); // 

}
