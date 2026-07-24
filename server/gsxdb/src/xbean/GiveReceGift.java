
package xbean;

public interface GiveReceGift extends mkdb.Bean {
	public GiveReceGift copy(); // 深拷贝
	public GiveReceGift toData(); // 一个 Data 实例
	public GiveReceGift toBean(); // 一个 Bean 实例
	public GiveReceGift toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GiveReceGift toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getGivegift(); // 发送礼物 key 为道具itemid value 为数量，作者 changhao
	public java.util.Map<Integer, Integer> getGivegiftAsData(); // 发送礼物 key 为道具itemid value 为数量，作者 changhao
	public java.util.Map<Integer, Integer> getRecegift(); // 接收礼物 key 为道具itemid value 为数量，作者 changhao
	public java.util.Map<Integer, Integer> getRecegiftAsData(); // 接收礼物 key 为道具itemid value 为数量，作者 changhao

}
