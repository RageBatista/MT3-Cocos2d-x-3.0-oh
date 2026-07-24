
package xbean;

public interface jiebaiAskInfo extends mkdb.Bean {
	public jiebaiAskInfo copy(); // 深拷贝
	public jiebaiAskInfo toData(); // 一个 Data 实例
	public jiebaiAskInfo toBean(); // 一个 Bean 实例
	public jiebaiAskInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public jiebaiAskInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getTitlename(); // 结拜称号名称
	public com.locojoy.base.Octets getTitlenameOctets(); // 结拜称号名称
	public java.util.Map<Long, String> getJiebaiinfo(); // 角色ID -> 个人称号
	public java.util.Map<Long, String> getJiebaiinfoAsData(); // 角色ID -> 个人称号

	public void setTitlename(String _v_); // 结拜称号名称
	public void setTitlenameOctets(com.locojoy.base.Octets _v_); // 结拜称号名称
}
