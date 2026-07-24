
package xbean;

public interface RoleProfessionRankList extends mkdb.Bean {
	public RoleProfessionRankList copy(); // 深拷贝
	public RoleProfessionRankList toData(); // 一个 Data 实例
	public RoleProfessionRankList toBean(); // 一个 Bean 实例
	public RoleProfessionRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleProfessionRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RoleProfessionRankRecord> getRecords(); // 
	public java.util.List<xbean.RoleProfessionRankRecord> getRecordsAsData(); // 

}
