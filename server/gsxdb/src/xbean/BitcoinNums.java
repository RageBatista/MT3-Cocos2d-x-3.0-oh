
package xbean;

public interface BitcoinNums extends mkdb.Bean {
	public BitcoinNums copy(); // 深拷贝
	public BitcoinNums toData(); // 一个 Data 实例
	public BitcoinNums toBean(); // 一个 Bean 实例
	public BitcoinNums toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BitcoinNums toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoin(); // 角色id -> 比特币，作者 system
	public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoinAsData(); // 角色id -> 比特币，作者 system

}
