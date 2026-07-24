
package xbean;

public interface varMap extends mkdb.Bean {
	public varMap copy(); // deep clone
	public varMap toData(); // a Data instance
	public varMap toBean(); // a Bean instance
	public varMap toDataIf(); // a Data instance If need. else return this
	public varMap toBeanIf(); // a Bean instance If need. else return this

	public java.util.Map<Integer, Integer> getV(); // 
	public java.util.Map<Integer, Integer> getVAsData(); // 

}
