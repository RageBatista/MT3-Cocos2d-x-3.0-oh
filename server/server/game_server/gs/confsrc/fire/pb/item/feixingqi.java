package fire.pb.item;


public class feixingqi implements mytools.ConvMain.Checkable ,Comparable<feixingqi>{

	public int compareTo(feixingqi o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public feixingqi(){
		super();
	}
	public feixingqi(feixingqi arg){
		this.id=arg.id ;
		this.map=arg.map ;
		this.mapx=arg.mapx ;
		this.mapy=arg.mapy ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * 
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public int map  = 0  ;
	
	public int getMap(){
		return this.map;
	}
	
	public void setMap(int v){
		this.map=v;
	}
	
	/**
	 * 
	 */
	public int mapx  = 0  ;
	
	public int getMapx(){
		return this.mapx;
	}
	
	public void setMapx(int v){
		this.mapx=v;
	}
	
	/**
	 * 
	 */
	public int mapy  = 0  ;
	
	public int getMapy(){
		return this.mapy;
	}
	
	public void setMapy(int v){
		this.mapy=v;
	}
	
	
};