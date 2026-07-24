
package xbean;

public interface xxx extends mkdb.Bean {
	public xxx copy(); // deep clone
	public xxx toData(); // a Data instance
	public xxx toBean(); // a Bean instance
	public xxx toDataIf(); // a Data instance If need. else return this
	public xxx toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Integer> getA(); // 
	public java.util.Set<Integer> getAAsData(); // 
	public xbean.yyy getB(); // 
	public String getC(); // 
	public com.locojoy.base.Octets getCOctets(); // 

	public void setC(String _v_); // 
	public void setCOctets(com.locojoy.base.Octets _v_); // 
}
