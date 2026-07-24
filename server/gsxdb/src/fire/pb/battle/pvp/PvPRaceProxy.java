package fire.pb.battle.pvp;

/**
 * PvP赛场代理
 * @作者XGM
 */
public abstract class PvPRaceProxy {

	/**
	 * 接受访问
	 * @参数访客
	 */
	public void acceptVisit(IPvPVisitor visitor) {
		visitor.visit(this);
	}
}
