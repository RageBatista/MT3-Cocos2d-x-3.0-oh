
package xbean;

public interface RoleLevelRankList extends mkdb.Bean {
	public RoleLevelRankList copy(); // 深拷贝
	public RoleLevelRankList toData(); // 一个 Data 实例
	public RoleLevelRankList toBean(); // 一个 Bean 实例
	public RoleLevelRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleLevelRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RoleLevelListRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.RoleLevelListRecord> getRecordsAsData(); // 所有的记录

}
