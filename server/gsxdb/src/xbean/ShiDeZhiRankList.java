
package xbean;

public interface ShiDeZhiRankList extends mkdb.Bean {
	public ShiDeZhiRankList copy(); // 深拷贝
	public ShiDeZhiRankList toData(); // 一个 Data 实例
	public ShiDeZhiRankList toBean(); // 一个 Bean 实例
	public ShiDeZhiRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ShiDeZhiRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.MasterRankRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.MasterRankRecord> getRecordsAsData(); // 所有的记录

}
