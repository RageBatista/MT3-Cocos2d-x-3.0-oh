
package xbean;

public interface NetBar extends mkdb.Bean {
	public NetBar copy(); // deep clone
	public NetBar toData(); // a Data instance
	public NetBar toBean(); // a Bean instance
	public NetBar toDataIf(); // a Data instance If need. else return this
	public NetBar toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // barid
	public String getBarname(); // barname
	public com.locojoy.base.Octets getBarnameOctets(); // barname
	public int getLevel(); // level

	public void setId(int _v_); // barid
	public void setBarname(String _v_); // barname
	public void setBarnameOctets(com.locojoy.base.Octets _v_); // barname
	public void setLevel(int _v_); // level
}
