
package xbean;

public interface BroadcastMsg extends mkdb.Bean {
	public BroadcastMsg copy(); // 深拷贝
	public BroadcastMsg toData(); // 一个 Data 实例
	public BroadcastMsg toBean(); // 一个 Bean 实例
	public BroadcastMsg toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BroadcastMsg toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public xbean.OfflineMsgProtocol getMsgprotocol(); // 
	public long getBroadtime(); // 
	public long getBroadendtime(); // 如果默认是0，则没有广播的结束时间

	public void setBroadtime(long _v_); // 
	public void setBroadendtime(long _v_); // 如果默认是0，则没有广播的结束时间
}
