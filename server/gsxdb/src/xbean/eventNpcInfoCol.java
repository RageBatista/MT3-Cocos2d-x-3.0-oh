
package xbean;

public interface eventNpcInfoCol extends mkdb.Bean {
	public eventNpcInfoCol copy(); // 深拷贝
	public eventNpcInfoCol toData(); // 一个 Data 实例
	public eventNpcInfoCol toBean(); // 一个 Bean 实例
	public eventNpcInfoCol toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public eventNpcInfoCol toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.eventNpcInfo> getNpcinfo(); // //npckey 对应的Npc状态信息
	public java.util.Map<Long, xbean.eventNpcInfo> getNpcinfoAsData(); // //npckey 对应的Npc状态信息

}
