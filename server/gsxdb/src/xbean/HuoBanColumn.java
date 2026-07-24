
package xbean;

public interface HuoBanColumn extends mkdb.Bean {
	public HuoBanColumn copy(); // 深拷贝
	public HuoBanColumn toData(); // 一个 Data 实例
	public HuoBanColumn toBean(); // 一个 Bean 实例
	public HuoBanColumn toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HuoBanColumn toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getFighthuobans(); // 所有参战伙伴
	public java.util.List<Integer> getFighthuobansAsData(); // 所有参战伙伴
	public java.util.Map<Integer, xbean.HuoBanInfo> getHuobans(); // 
	public java.util.Map<Integer, xbean.HuoBanInfo> getHuobansAsData(); // 
	public int getViphuoban(); // vip伙伴数量
	public int getWeek(); // 当前周数,计算伙伴状态的时候使用

	public void setViphuoban(int _v_); // vip伙伴数量
	public void setWeek(int _v_); // 当前周数,计算伙伴状态的时候使用
}
