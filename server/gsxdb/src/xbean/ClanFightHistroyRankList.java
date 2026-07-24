
package xbean;

public interface ClanFightHistroyRankList extends mkdb.Bean {
	public ClanFightHistroyRankList copy(); // 深拷贝
	public ClanFightHistroyRankList toData(); // 一个 Data 实例
	public ClanFightHistroyRankList toBean(); // 一个 Bean 实例
	public ClanFightHistroyRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanFightHistroyRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ClanFightHistroyRankRecord> getRecords(); // 公会战历史记录，作者 changhao
	public java.util.List<xbean.ClanFightHistroyRankRecord> getRecordsAsData(); // 公会战历史记录，作者 changhao

}
