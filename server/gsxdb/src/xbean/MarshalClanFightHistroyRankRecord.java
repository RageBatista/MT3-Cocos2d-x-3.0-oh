
package xbean;

public interface MarshalClanFightHistroyRankRecord extends mkdb.Bean {
	public MarshalClanFightHistroyRankRecord copy(); // 深拷贝
	public MarshalClanFightHistroyRankRecord toData(); // 一个 Data 实例
	public MarshalClanFightHistroyRankRecord toBean(); // 一个 Bean 实例
	public MarshalClanFightHistroyRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalClanFightHistroyRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getClanid(); // 公会id，作者 changhao
	public String getClanname(); // 公会名字，作者 changhao
	public com.locojoy.base.Octets getClannameOctets(); // 公会名字，作者 changhao
	public int getClanlevel(); // 公会等级，作者 changhao
	public int getFightcount(); // 战斗次数，作者 changhao
	public int getWincount(); // 胜利次数，作者 changhao
	public int getTotalscroe(); // 公会战积分，作者 changhao

	public void setClanid(long _v_); // 公会id，作者 changhao
	public void setClanname(String _v_); // 公会名字，作者 changhao
	public void setClannameOctets(com.locojoy.base.Octets _v_); // 公会名字，作者 changhao
	public void setClanlevel(int _v_); // 公会等级，作者 changhao
	public void setFightcount(int _v_); // 战斗次数，作者 changhao
	public void setWincount(int _v_); // 胜利次数，作者 changhao
	public void setTotalscroe(int _v_); // 公会战积分，作者 changhao
}
