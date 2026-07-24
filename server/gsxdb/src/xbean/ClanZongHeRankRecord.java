
package xbean;

public interface ClanZongHeRankRecord extends mkdb.Bean {
	public ClanZongHeRankRecord copy(); // 深拷贝
	public ClanZongHeRankRecord toData(); // 一个 Data 实例
	public ClanZongHeRankRecord toBean(); // 一个 Bean 实例
	public ClanZongHeRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanZongHeRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRank(); // 排名
	public long getClankey(); // 公会表唯一键值
	public String getClanname(); // 公会名称
	public com.locojoy.base.Octets getClannameOctets(); // 公会名称
	public int getLevel(); // 公会等级
	public int getZonghe(); // 综合，作者 changhao
	public long getTriggertime(); // 触发时间，作者 changhao

	public void setRank(int _v_); // 排名
	public void setClankey(long _v_); // 公会表唯一键值
	public void setClanname(String _v_); // 公会名称
	public void setClannameOctets(com.locojoy.base.Octets _v_); // 公会名称
	public void setLevel(int _v_); // 公会等级
	public void setZonghe(int _v_); // 综合，作者 changhao
	public void setTriggertime(long _v_); // 触发时间，作者 changhao
}
