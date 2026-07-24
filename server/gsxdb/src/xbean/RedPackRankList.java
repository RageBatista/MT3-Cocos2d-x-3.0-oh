
package xbean;

public interface RedPackRankList extends mkdb.Bean {
	public RedPackRankList copy(); // 深拷贝
	public RedPackRankList toData(); // 一个 Data 实例
	public RedPackRankList toBean(); // 一个 Bean 实例
	public RedPackRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RedPackRecord> getRecords(); // 红包所有的记录，作者 changhao
	public java.util.List<xbean.RedPackRecord> getRecordsAsData(); // 红包所有的记录，作者 changhao

}
