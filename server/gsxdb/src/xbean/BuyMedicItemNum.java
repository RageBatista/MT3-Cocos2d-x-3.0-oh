
package xbean;

public interface BuyMedicItemNum extends mkdb.Bean {
	public BuyMedicItemNum copy(); // 深拷贝
	public BuyMedicItemNum toData(); // 一个 Data 实例
	public BuyMedicItemNum toBean(); // 一个 Bean 实例
	public BuyMedicItemNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BuyMedicItemNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBuynum(); // 药房道具购买数量
	public int getImpeachdaynum(); // 发起弹劾次数

	public void setBuynum(int _v_); // 药房道具购买数量
	public void setImpeachdaynum(int _v_); // 发起弹劾次数
}
