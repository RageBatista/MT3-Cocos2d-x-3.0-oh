package fire.pb.gm;

/***
 * 创建公会战匹配，作者 changhao
 * @作者管理员
 *
 */
public class GM_clanfightcreatematch extends GMCommand {

	@Override
	boolean exec(String[] args) {
		if (args.length < 1) {
			sendToGM(usage());
			return false;
		}

		try {
			
		} catch (java.lang.NumberFormatException e) {
	
		}

		new fire.pb.clan.fight.PClanFightCreateMatch(true).submit();
		
		return true;
	}

	@Override
	String usage() {
		return null;
	}

}
