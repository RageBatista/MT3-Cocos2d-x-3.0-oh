
package xbean;

public interface RoleTradingHisRecord extends mkdb.Bean {
	public RoleTradingHisRecord copy(); // 深拷贝
	public RoleTradingHisRecord toData(); // 一个 Data 实例
	public RoleTradingHisRecord toBean(); // 一个 Bean 实例
	public RoleTradingHisRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleTradingHisRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getTradingid(); // 挂单号
	public com.locojoy.base.Octets getTradingidOctets(); // 挂单号
	public int getTradingtype(); // 交易类型  0买入  1出售
	public int getCurnum(); // 当前数量
	public int getAllnum(); // 总数量
	public int getPrice(); // 价格
	public long getCreatetime(); // 挂单时间
	public long getTradingtime(); // 交易时间

	public void setTradingid(String _v_); // 挂单号
	public void setTradingidOctets(com.locojoy.base.Octets _v_); // 挂单号
	public void setTradingtype(int _v_); // 交易类型  0买入  1出售
	public void setCurnum(int _v_); // 当前数量
	public void setAllnum(int _v_); // 总数量
	public void setPrice(int _v_); // 价格
	public void setCreatetime(long _v_); // 挂单时间
	public void setTradingtime(long _v_); // 交易时间
}
