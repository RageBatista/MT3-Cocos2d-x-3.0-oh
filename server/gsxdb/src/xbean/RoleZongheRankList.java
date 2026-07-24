
package xbean;

public interface RoleZongheRankList extends mkdb.Bean {
	public RoleZongheRankList copy(); // 深拷贝
	public RoleZongheRankList toData(); // 一个 Data 实例
	public RoleZongheRankList toBean(); // 一个 Bean 实例
	public RoleZongheRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleZongheRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RoleZongheRankRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.RoleZongheRankRecord> getRecordsAsData(); // 所有的记录

}
