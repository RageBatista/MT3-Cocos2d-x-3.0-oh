
package xbean;

public interface fxbean0 extends mkdb.Bean {
	public fxbean0 copy(); // deep clone
	public fxbean0 toData(); // a Data instance
	public fxbean0 toBean(); // a Bean instance
	public fxbean0 toDataIf(); // a Data instance If need. else return this
	public fxbean0 toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Boolean> getA(); // 
	public java.util.Set<Boolean> getAAsData(); // 
	public java.util.List<xbean.fcbean> getB(); // 
	public java.util.List<xbean.fcbean> getBAsData(); // 

}
