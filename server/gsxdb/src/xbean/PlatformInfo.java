
package xbean;

public interface PlatformInfo extends mkdb.Bean {
	public PlatformInfo copy(); // 深拷贝
	public PlatformInfo toData(); // 一个 Data 实例
	public PlatformInfo toBean(); // 一个 Bean 实例
	public PlatformInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PlatformInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 商家id
	public String getName(); // 商家名，UTF-16LE编码
	public com.locojoy.base.Octets getNameOctets(); // 商家名，UTF-16LE编码
	public int getDiscount(); // 折扣介于1-100之间

	public void setId(int _v_); // 商家id
	public void setName(String _v_); // 商家名，UTF-16LE编码
	public void setNameOctets(com.locojoy.base.Octets _v_); // 商家名，UTF-16LE编码
	public void setDiscount(int _v_); // 折扣介于1-100之间
}
