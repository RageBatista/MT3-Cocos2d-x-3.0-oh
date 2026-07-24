
package xbean;

public interface YybFushiNum extends mkdb.Bean {
	public YybFushiNum copy(); // 深拷贝
	public YybFushiNum toData(); // 一个 Data 实例
	public YybFushiNum toBean(); // 一个 Bean 实例
	public YybFushiNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public YybFushiNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBalance(); // 现金充值符石总数
	public int getGenbalance(); // 系统赠送符石数
	public int getSaveamt(); // 累计充值金额
	public long getFushiall(); // 累计符石总数，包括所有产出途径的符石数

	public void setBalance(int _v_); // 现金充值符石总数
	public void setGenbalance(int _v_); // 系统赠送符石数
	public void setSaveamt(int _v_); // 累计充值金额
	public void setFushiall(long _v_); // 累计符石总数，包括所有产出途径的符石数
}
