
package xbean;

public interface NpcInfo extends mkdb.Bean {
	public NpcInfo copy(); // 深拷贝
	public NpcInfo toData(); // 一个 Data 实例
	public NpcInfo toBean(); // 一个 Bean 实例
	public NpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getIsinbattle(); // 0表示不在战斗中,1表示在战斗中,2表示在战斗中且已经到期,战斗结束就要删除

	public void setIsinbattle(int _v_); // 0表示不在战斗中,1表示在战斗中,2表示在战斗中且已经到期,战斗结束就要删除
}
