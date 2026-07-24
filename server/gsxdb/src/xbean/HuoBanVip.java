
package xbean;

public interface HuoBanVip extends mkdb.Bean {
	public HuoBanVip copy(); // 深拷贝
	public HuoBanVip toData(); // 一个 Data 实例
	public HuoBanVip toBean(); // 一个 Bean 实例
	public HuoBanVip toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HuoBanVip toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getHuobans(); // vip免费的数量
	public java.util.List<Integer> getHuobansAsData(); // vip免费的数量

}
