
package xbean;

public interface EDayPay extends mkdb.Bean {
	public EDayPay copy(); // 深拷贝
	public EDayPay toData(); // 一个 Data 实例
	public EDayPay toBean(); // 一个 Bean 实例
	public EDayPay toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EDayPay toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.DayPay> getRoleid2daypay(); // 队伍分赃链表，作者 changhao
	public java.util.Map<Long, xbean.DayPay> getRoleid2daypayAsData(); // 队伍分赃链表，作者 changhao

}
