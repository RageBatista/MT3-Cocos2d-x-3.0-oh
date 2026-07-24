
package xbean;

public interface RefreshMonsterNpcInfo extends mkdb.Bean {
	public RefreshMonsterNpcInfo copy(); // 深拷贝
	public RefreshMonsterNpcInfo toData(); // 一个 Data 实例
	public RefreshMonsterNpcInfo toBean(); // 一个 Bean 实例
	public RefreshMonsterNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RefreshMonsterNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getNpcinfos(); // //npckey 对应的战斗状态 0=空闲  1=战斗中
	public java.util.Map<Long, Integer> getNpcinfosAsData(); // //npckey 对应的战斗状态 0=空闲  1=战斗中

}
