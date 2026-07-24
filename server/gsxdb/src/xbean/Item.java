
package xbean;

public interface Item extends mkdb.Bean {
	public Item copy(); // 深拷贝
	public Item toData(); // 一个 Data 实例
	public Item toBean(); // 一个 Bean 实例
	public Item toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Item toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 物品编号
	public int getFlags(); // 标志，叠加的时候，flags 也 OR 叠加
	public int getPosition(); // 背包属性，位置。从0开始编号
	public int getNumber(); // 数量
	public java.util.Map<Integer, Integer> getNumbermap(); // 数量
	public java.util.Map<Integer, Integer> getNumbermapAsData(); // 数量
	public long getTimeout(); // 到期时间。如果为0，代表没有时间限制
	public long getExtid(); // 扩展动态属性
	public long getUniqueid(); // 物品的唯一id
	public long getLoseeffecttime(); // 物品失效时间
	public long getMarkettime(); // 摆摊道具冻结时间
	public int getTypeid(); // 物品类型

	public void setId(int _v_); // 物品编号
	public void setFlags(int _v_); // 标志，叠加的时候，flags 也 OR 叠加
	public void setPosition(int _v_); // 背包属性，位置。从0开始编号
	public void setNumber(int _v_); // 数量
	public void setTimeout(long _v_); // 到期时间。如果为0，代表没有时间限制
	public void setExtid(long _v_); // 扩展动态属性
	public void setUniqueid(long _v_); // 物品的唯一id
	public void setLoseeffecttime(long _v_); // 物品失效时间
	public void setMarkettime(long _v_); // 摆摊道具冻结时间
	public void setTypeid(int _v_); // 物品类型
}
