
package xbean;

public interface ReceFlowerRankList extends mkdb.Bean {
	public ReceFlowerRankList copy(); // 深拷贝
	public ReceFlowerRankList toData(); // 一个 Data 实例
	public ReceFlowerRankList toBean(); // 一个 Bean 实例
	public ReceFlowerRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ReceFlowerRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ReceFlowerRecord> getRecords(); // 送花记录，作者 changhao
	public java.util.List<xbean.ReceFlowerRecord> getRecordsAsData(); // 送花记录，作者 changhao

}
