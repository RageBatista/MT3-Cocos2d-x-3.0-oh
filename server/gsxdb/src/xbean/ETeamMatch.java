
package xbean;

public interface ETeamMatch extends mkdb.Bean {
	public ETeamMatch copy(); // 深拷贝
	public ETeamMatch toData(); // 一个 Data 实例
	public ETeamMatch toBean(); // 一个 Bean 实例
	public ETeamMatch toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ETeamMatch toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.TeamMatch> getRoleid2matchdata(); // 
	public java.util.Map<Long, xbean.TeamMatch> getRoleid2matchdataAsData(); // 
	public java.util.Map<Long, xbean.TeamMatch> getTeamid2matchdata(); // 
	public java.util.Map<Long, xbean.TeamMatch> getTeamid2matchdataAsData(); // 
	public java.util.List<xbean.TeamMatch> getTeammatchdatalist(); // 
	public java.util.List<xbean.TeamMatch> getTeammatchdatalistAsData(); // 
	public java.util.List<xbean.TeamMatch> getRolematchdatalist(); // 
	public java.util.List<xbean.TeamMatch> getRolematchdatalistAsData(); // 

}
