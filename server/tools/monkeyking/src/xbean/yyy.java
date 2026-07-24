
package xbean;

public interface yyy extends mkdb.Bean {
	public yyy copy(); // deep clone
	public yyy toData(); // a Data instance
	public yyy toBean(); // a Bean instance
	public yyy toDataIf(); // a Data instance If need. else return this
	public yyy toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Integer> getA(); // 
	public java.util.Set<Integer> getAAsData(); // 
	public int getB(); // 
	public String getC(); // 
	public com.locojoy.base.Octets getCOctets(); // 

	public void setB(int _v_); // 
	public void setC(String _v_); // 
	public void setCOctets(com.locojoy.base.Octets _v_); // 
}
