
package xbean;

public interface ClanFights extends mkdb.Bean {
	public ClanFights copy(); // 深拷贝
	public ClanFights toData(); // 一个 Data 实例
	public ClanFights toBean(); // 一个 Bean 实例
	public ClanFights toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanFights toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getCreatetime(); // 创建时间，作者 changhao
	public java.util.Map<Long, xbean.ClanFight> getClan1vschan2(); // 配对的公会战，作者 changhao
	public java.util.Map<Long, xbean.ClanFight> getClan1vschan2AsData(); // 配对的公会战，作者 changhao

	public void setCreatetime(long _v_); // 创建时间，作者 changhao
}
