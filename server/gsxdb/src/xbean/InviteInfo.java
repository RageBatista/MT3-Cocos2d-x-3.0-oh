
package xbean;

public interface InviteInfo extends mkdb.Bean {
	public InviteInfo copy(); // 深拷贝
	public InviteInfo toData(); // 一个 Data 实例
	public InviteInfo toBean(); // 一个 Bean 实例
	public InviteInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InviteInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public boolean getBeinginvited(); // 
	public xbean.TeamInvite getInviting(); // 
	public java.util.List<xbean.TeamInvite> getInvited(); // 
	public java.util.List<xbean.TeamInvite> getInvitedAsData(); // 

	public void setBeinginvited(boolean _v_); // 
}
