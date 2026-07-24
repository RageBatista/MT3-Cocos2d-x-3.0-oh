
package xbean;

public interface MarketFloatingGoods extends mkdb.Bean {
	public MarketFloatingGoods copy(); // 深拷贝
	public MarketFloatingGoods toData(); // 一个 Data 实例
	public MarketFloatingGoods toBean(); // 一个 Bean 实例
	public MarketFloatingGoods toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarketFloatingGoods toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public float getFloatingmin(); // 价格下限
	public float getFloatingmax(); // 价格上限
	public float getFloatingprice(); // 浮动价格系数
	public int getBasehangordernum(); // 基准挂单量
	public int getBasesalenum(); // 基准成交量
	public int getHangordernum(); // 挂单量
	public int getSalenum(); // 当期成交量
	public int getPriorperiodprice(); // 上期价格
	public int getPrice(); // 当前价格
	public int getTotalmoney(); // 本期售卖总金额

	public void setFloatingmin(float _v_); // 价格下限
	public void setFloatingmax(float _v_); // 价格上限
	public void setFloatingprice(float _v_); // 浮动价格系数
	public void setBasehangordernum(int _v_); // 基准挂单量
	public void setBasesalenum(int _v_); // 基准成交量
	public void setHangordernum(int _v_); // 挂单量
	public void setSalenum(int _v_); // 当期成交量
	public void setPriorperiodprice(int _v_); // 上期价格
	public void setPrice(int _v_); // 当前价格
	public void setTotalmoney(int _v_); // 本期售卖总金额
}
