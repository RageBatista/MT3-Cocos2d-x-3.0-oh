
package xbean;

public interface MarshalGiveFlowerRecord extends mkdb.Bean {
	public MarshalGiveFlowerRecord copy(); // 深拷贝
	public MarshalGiveFlowerRecord toData(); // 一个 Data 实例
	public MarshalGiveFlowerRecord toBean(); // 一个 Bean 实例
	public MarshalGiveFlowerRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalGiveFlowerRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id，作者 changhao
	public String getName(); // 玩家名字，作者 changhao
	public com.locojoy.base.Octets getNameOctets(); // 玩家名字，作者 changhao
	public int getSchool(); // 玩家职业，作者 changhao
	public long getNum(); // 送花，作者 changhao

	public void setRoleid(long _v_); // 角色id，作者 changhao
	public void setName(String _v_); // 玩家名字，作者 changhao
	public void setNameOctets(com.locojoy.base.Octets _v_); // 玩家名字，作者 changhao
	public void setSchool(int _v_); // 玩家职业，作者 changhao
	public void setNum(long _v_); // 送花，作者 changhao
}
