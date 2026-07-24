
package xbean;

public interface BroadcastMsgList extends mkdb.Bean {
	public BroadcastMsgList copy(); // 深拷贝
	public BroadcastMsgList toData(); // 一个 Data 实例
	public BroadcastMsgList toBean(); // 一个 Bean 实例
	public BroadcastMsgList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BroadcastMsgList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.BroadcastMsg> getMsglist(); // 
	public java.util.List<xbean.BroadcastMsg> getMsglistAsData(); // 

}
