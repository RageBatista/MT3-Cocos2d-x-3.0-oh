
package xbean;

public interface OfflineMsgList extends mkdb.Bean {
	public OfflineMsgList copy(); // 深拷贝
	public OfflineMsgList toData(); // 一个 Data 实例
	public OfflineMsgList toBean(); // 一个 Bean 实例
	public OfflineMsgList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OfflineMsgList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.OfflineMsgProtocol> getProtocollist(); // 
	public java.util.List<xbean.OfflineMsgProtocol> getProtocollistAsData(); // 

}
