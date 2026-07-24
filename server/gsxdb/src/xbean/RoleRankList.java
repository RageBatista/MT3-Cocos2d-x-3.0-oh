
package xbean;

public interface RoleRankList extends mkdb.Bean {
	public RoleRankList copy(); // 深拷贝
	public RoleRankList toData(); // 一个 Data 实例
	public RoleRankList toBean(); // 一个 Bean 实例
	public RoleRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RoleRankRecord> getRecords(); // 
	public java.util.List<xbean.RoleRankRecord> getRecordsAsData(); // 

}
