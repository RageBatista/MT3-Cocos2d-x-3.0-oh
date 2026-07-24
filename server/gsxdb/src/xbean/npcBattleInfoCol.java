
package xbean;

public interface npcBattleInfoCol extends mkdb.Bean {
	public npcBattleInfoCol copy(); // 深拷贝
	public npcBattleInfoCol toData(); // 一个 Data 实例
	public npcBattleInfoCol toBean(); // 一个 Bean 实例
	public npcBattleInfoCol toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public npcBattleInfoCol toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getBattleroles(); // key为roleid,value是role对应队伍的人数
	public java.util.Map<Long, Integer> getBattlerolesAsData(); // key为roleid,value是role对应队伍的人数

}
