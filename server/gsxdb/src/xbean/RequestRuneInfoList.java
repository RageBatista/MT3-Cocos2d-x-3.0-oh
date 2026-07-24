
package xbean;

public interface RequestRuneInfoList extends mkdb.Bean {
	public RequestRuneInfoList copy(); // 深拷贝
	public RequestRuneInfoList toData(); // 一个 Data 实例
	public RequestRuneInfoList toBean(); // 一个 Bean 实例
	public RequestRuneInfoList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RequestRuneInfoList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RequestRuneInfo> getRequestrunelists(); // 
	public java.util.List<xbean.RequestRuneInfo> getRequestrunelistsAsData(); // 

}
