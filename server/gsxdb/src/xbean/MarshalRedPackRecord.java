
package xbean;

public interface MarshalRedPackRecord extends mkdb.Bean {
	public MarshalRedPackRecord copy(); // 深拷贝
	public MarshalRedPackRecord toData(); // 一个 Data 实例
	public MarshalRedPackRecord toBean(); // 一个 Bean 实例
	public MarshalRedPackRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalRedPackRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id，作者 changhao
	public String getName(); // 玩家名字，作者 changhao
	public com.locojoy.base.Octets getNameOctets(); // 玩家名字，作者 changhao
	public int getSchool(); // 玩家职业，作者 changhao
	public long getNum(); // 符石数量(普通服)金币数量(点卡服)，作者 changhao

	public void setRoleid(long _v_); // 角色id，作者 changhao
	public void setName(String _v_); // 玩家名字，作者 changhao
	public void setNameOctets(com.locojoy.base.Octets _v_); // 玩家名字，作者 changhao
	public void setSchool(int _v_); // 玩家职业，作者 changhao
	public void setNum(long _v_); // 符石数量(普通服)金币数量(点卡服)，作者 changhao
}
