
package xbean;

public interface NormalItem extends mkdb.Bean {
	public NormalItem copy(); // 深拷贝
	public NormalItem toData(); // 一个 Data 实例
	public NormalItem toBean(); // 一个 Bean 实例
	public NormalItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NormalItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getId(); // 主键id
	public int getFirstno(); // 一级菜单
	public int getTwono(); // 二级菜单
	public int getThreeno(); // 三级菜单
	public long getUniquid(); // 工具唯一ID
	public int getKey(); // 背包中key
	public int getItemid(); // 工具编号
	public long getExtid(); // 道具属性扩展id
	public String getName(); // 道具名称
	public com.locojoy.base.Octets getNameOctets(); // 道具名称
	public long getRoleid(); // 拥有者id
	public int getLevel(); // 道具等级
	public int getNumber(); // 道具数量
	public int getPrice(); // 道具价格
	public int getAttentionnumber(); // 关注数量
	public long getShowtime(); // 公示时间
	public long getExpiretime(); // 到期时间

	public void setId(long _v_); // 主键id
	public void setFirstno(int _v_); // 一级菜单
	public void setTwono(int _v_); // 二级菜单
	public void setThreeno(int _v_); // 三级菜单
	public void setUniquid(long _v_); // 工具唯一ID
	public void setKey(int _v_); // 背包中key
	public void setItemid(int _v_); // 工具编号
	public void setExtid(long _v_); // 道具属性扩展id
	public void setName(String _v_); // 道具名称
	public void setNameOctets(com.locojoy.base.Octets _v_); // 道具名称
	public void setRoleid(long _v_); // 拥有者id
	public void setLevel(int _v_); // 道具等级
	public void setNumber(int _v_); // 道具数量
	public void setPrice(int _v_); // 道具价格
	public void setAttentionnumber(int _v_); // 关注数量
	public void setShowtime(long _v_); // 公示时间
	public void setExpiretime(long _v_); // 到期时间
}
