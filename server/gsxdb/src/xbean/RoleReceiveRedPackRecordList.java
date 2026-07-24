
package xbean;

public interface RoleReceiveRedPackRecordList extends mkdb.Bean {
	public RoleReceiveRedPackRecordList copy(); // 深拷贝
	public RoleReceiveRedPackRecordList toData(); // 一个 Data 实例
	public RoleReceiveRedPackRecordList toBean(); // 一个 Bean 实例
	public RoleReceiveRedPackRecordList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleReceiveRedPackRecordList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<String, xbean.RoleReceiveRedPackRecord> getRolereceiveredpacklist(); // 
	public java.util.Map<String, xbean.RoleReceiveRedPackRecord> getRolereceiveredpacklistAsData(); // 

}
