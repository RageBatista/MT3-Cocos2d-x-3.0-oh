
package xbean;

public interface GiveFlowerRankList extends mkdb.Bean {
	public GiveFlowerRankList copy(); // 深拷贝
	public GiveFlowerRankList toData(); // 一个 Data 实例
	public GiveFlowerRankList toBean(); // 一个 Bean 实例
	public GiveFlowerRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GiveFlowerRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.GiveFlowerRecord> getRecords(); // 送花记录，作者 changhao
	public java.util.List<xbean.GiveFlowerRecord> getRecordsAsData(); // 送花记录，作者 changhao

}
