
package xbean;

public interface AttentionGoodsBean extends mkdb.Bean {
	public AttentionGoodsBean copy(); // 深拷贝
	public AttentionGoodsBean toData(); // 一个 Data 实例
	public AttentionGoodsBean toBean(); // 一个 Bean 实例
	public AttentionGoodsBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AttentionGoodsBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getId(); // 物品类型+数据库id
	public com.locojoy.base.Octets getIdOctets(); // 物品类型+数据库id
	public long getShowtime(); // 公示时间
	public long getExpiretime(); // 物品过期时间

	public void setId(String _v_); // 物品类型+数据库id
	public void setIdOctets(com.locojoy.base.Octets _v_); // 物品类型+数据库id
	public void setShowtime(long _v_); // 公示时间
	public void setExpiretime(long _v_); // 物品过期时间
}
