
package xbean;

public interface GoodsBusiness extends mkdb.Bean {
	public GoodsBusiness copy(); // 深拷贝
	public GoodsBusiness toData(); // 一个 Data 实例
	public GoodsBusiness toBean(); // 一个 Bean 实例
	public GoodsBusiness toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GoodsBusiness toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getBuynum(); // 本期购买的数量
	public long getSalenum(); // 本期售卖的数量
	public long getLastnum(); // 上期成交量
	public int getPriorperiodprice(); // 上期价格
	public int getPrice(); // 商品价格
	public int getCount(); // 周期成交量小于等于零的次数,降价后次数清零重新计数

	public void setBuynum(long _v_); // 本期购买的数量
	public void setSalenum(long _v_); // 本期售卖的数量
	public void setLastnum(long _v_); // 上期成交量
	public void setPriorperiodprice(int _v_); // 上期价格
	public void setPrice(int _v_); // 商品价格
	public void setCount(int _v_); // 周期成交量小于等于零的次数,降价后次数清零重新计数
}
