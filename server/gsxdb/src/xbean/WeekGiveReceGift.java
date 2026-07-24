
package xbean;

public interface WeekGiveReceGift extends mkdb.Bean {
	public WeekGiveReceGift copy(); // 深拷贝
	public WeekGiveReceGift toData(); // 一个 Data 实例
	public WeekGiveReceGift toBean(); // 一个 Bean 实例
	public WeekGiveReceGift toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WeekGiveReceGift toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.GiveReceGift> getWeekdata(); // 
	public java.util.Map<Long, xbean.GiveReceGift> getWeekdataAsData(); // 

}
