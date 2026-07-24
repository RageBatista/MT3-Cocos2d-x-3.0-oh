
package xbean;

public interface timerNpcInfoCol extends mkdb.Bean {
	public timerNpcInfoCol copy(); // 深拷贝
	public timerNpcInfoCol toData(); // 一个 Data 实例
	public timerNpcInfoCol toBean(); // 一个 Bean 实例
	public timerNpcInfoCol toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public timerNpcInfoCol toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.timerNpcInfo> getNpcinfo(); // //npckey 对应的Npc状态信息
	public java.util.Map<Long, xbean.timerNpcInfo> getNpcinfoAsData(); // //npckey 对应的Npc状态信息

}
