
package xbean;

public interface ClanFightRaceRankList extends mkdb.Bean {
	public ClanFightRaceRankList copy(); // 深拷贝
	public ClanFightRaceRankList toData(); // 一个 Data 实例
	public ClanFightRaceRankList toBean(); // 一个 Bean 实例
	public ClanFightRaceRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanFightRaceRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ClanFightRaceRankRecord> getRecords(); // 送花记录，作者 changhao
	public java.util.List<xbean.ClanFightRaceRankRecord> getRecordsAsData(); // 送花记录，作者 changhao

}
