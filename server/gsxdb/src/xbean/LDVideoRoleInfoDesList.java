
package xbean;

public interface LDVideoRoleInfoDesList extends mkdb.Bean {
	public LDVideoRoleInfoDesList copy(); // 深拷贝
	public LDVideoRoleInfoDesList toData(); // 一个 Data 实例
	public LDVideoRoleInfoDesList toBean(); // 一个 Bean 实例
	public LDVideoRoleInfoDesList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LDVideoRoleInfoDesList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.LDVideoRoleInfoDes> getLdvideoroleinfodeslistall(); // 生死战录像信息
	public java.util.List<xbean.LDVideoRoleInfoDes> getLdvideoroleinfodeslistallAsData(); // 生死战录像信息

}
