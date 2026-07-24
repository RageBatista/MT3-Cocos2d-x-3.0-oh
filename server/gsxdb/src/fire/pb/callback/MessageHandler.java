package fire.pb.callback;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import org.apache.log4j.Logger;
import fire.pb.fushi.PPayOrderResponse;
import fire.pb.main.ConfigManager;
import com.fasterxml.jackson.databind.JsonNode;
import fire.util.ExceptionHandler;
import fire.util.JsonUtil;


/**
 * @作者直流
 * 消息分发
 */
public class MessageHandler {
	public static final Logger logger = Logger.getLogger("RECHARGE");
	
	public static void handleMessage(Message revMsg, SocketChannel sc) {
		try {
			revMsg.readHeader();
		} catch (ArrayIndexOutOfBoundsException e) {
			logger.error("MessageHandler.handleMessage:readHeader异常:" + e);
			ExceptionHandler.handleException(e, "fire.pb.callback.MessageHandler.handleMessage - 读取消息头");
		}
		switch(revMsg.getMessageNum())	{
		case 3:
			doPay(revMsg, sc);
			break;
		default:
			logger.info("MessageHandler.handleMessage:未定义的消息号=" + revMsg.getMessageNum());
			break;
		}
	}
	
	private static void doVersion3Pay(Message revMsg, SocketChannel sc, short iVersion) {
		//全部：
		logger.warn("MessageHandler.doVersion3Pay:版本3的充值回调不做处理!");
	}
	
	private static void doVersion5Pay(Message revMsg, SocketChannel sc, short iVersion) {
		String strPayData = revMsg.readString();
		String strSign = revMsg.readString();
		logger.info("MessageHandler.doVersion5Pay:iVersion=" + iVersion + "充值回调处理开始!strPayData=" + strPayData + ",strSign=" + strSign);
		String strGameKey = ConfigManager.getGameKey();
		String strPrepare = strGameKey + iVersion + strPayData;
		String strMySign = Encrypter.MD5(strPrepare);
		if(!strMySign.toLowerCase().equals(strSign.toLowerCase())) {
			logger.error("MessageHandler.doVersion5Pay:iVersion=" + iVersion + "充值回调签名效验失败!");
			sendFailure(sc);
		} else {
			logger.info("MessageHandler.doVersion5Pay:iVersion=" + iVersion + "充值回调处理开始!签名效验成功.");
			//{“OrderId”：“0406d4941ca84ec8acc3ebd7f0c9be0128787”，“频道”：“locojoy”，“AppId”：“10000”，“ConsumeId”：“4 1137979117087590452","PlatformId":"200000001","ProductId":"100001","ProductCount":1,"Money":"10.00","货币":"CNY","积分":0,"奖励积分":0,"CpInfo":"MTAxMDB8MjAwOTAwMDAwfDQwMDYyMzU2fDE5Mi4xNjguMC4x fDMzOjY2OjQ0OjU1OjY2Ojc3fA==","CpExtra":"","ServerId":10100,"RoleId":40062356,"OrderTime":1444966580}
			try {
				JsonNode jsonObject = JsonUtil.parseJson(strPayData);
				String strOrderId = jsonObject.get("OrderId").asText();
				String strChannel = jsonObject.get("Channel").asText();
//				String strAppId = jsonObject.get("AppId").asText();
//				String strConsumeId = jsonObject.get("ConsumeId").asText();
				String strPlatformId = jsonObject.get("PlatformId").asText();
//				String strProductId = jsonObject.get("ProductId").asText();
//				int iProductCount = jsonObject.get("ProductCount").asInt();
//				Double dMoney = jsonObject.get("Money").asDouble();
//				String strCurrency = jsonObject.get("Currency").asText();
//				int iPoints = jsonObject.get("Points").asInt();
//				int iBonusPoints = jsonObject.get("BonusPoints").asInt();
				String strCpInfo = jsonObject.get("CpInfo").asText();
//				String strCpExtra = jsonObject.get("CpExtra").asText();
				int iServerId = jsonObject.get("ServerId").asInt();
				long lRoleId = jsonObject.get("RoleId").asLong();
//				int iOrderTime = jsonObject.get("OrderTime").asInt();
				logger.info("MessageHandler.doVersion5Pay:OrderId=" + strOrderId + ",Channel=" + strChannel + ",PlatformId=" + strPlatformId
						 + ",ServerId=" + iServerId + ",RoleId=" + lRoleId);
				final String decodeCpInfo = ParseUtil.getFromBase64(strCpInfo); 
				if(null != decodeCpInfo){
					logger.info("MessageHandler.doVersion5Pay decodeCpInfo=" + decodeCpInfo);
				} else {
					logger.error("MessageHandler.doVersion5Pay decodeCpInfo=" + decodeCpInfo);
					sendFailure(sc);
					return;
				}
				
				String selfchannel = "";
				String[] cpinfos = decodeCpInfo.split("\\|");
				String cpinfoGamesn = "";
				if(strChannel.equals("1SDK")){
					if(cpinfos.length < 7){
						logger.error("MessageHandler.doVersion5Pay cpinfos=" + cpinfos.toString() + ",length=" + cpinfos.length);
						sendFailure(sc);
						return;
					} else if(cpinfos.length == 7) {
						//String cpinfoServerId = cpinfos[0];
						String cpinfoSelfChannel = cpinfos[1];
						selfchannel = cpinfoSelfChannel;
						String cpinfoRoleId = cpinfos[2];
						//String cpinfoIp = cpinfos[3];
						//String cpinfoDeviceId = cpinfos[4];
						//String cpinfoGameId = cpinfos[5];
						//String cpinfoProductId = cpinfos[6];
						cpinfoGamesn = "-1";
						logger.info("MessageHandler.doVersion5Pay roleId=" + cpinfoRoleId + ",gamesn=" + cpinfoGamesn + ",selfchannel=" + selfchannel);
					} else {
						//String cpinfoServerId = cpinfos[0];
						String cpinfoSelfChannel = cpinfos[1];
						selfchannel = cpinfoSelfChannel;
						String cpinfoRoleId = cpinfos[2];
						//String cpinfoIp = cpinfos[3];
						//String cpinfoDeviceId = cpinfos[4];
						//String cpinfoGameId = cpinfos[5];
						//String cpinfoProductId = cpinfos[6];
						cpinfoGamesn = cpinfos[cpinfos.length - 1];
						logger.info("MessageHandler.doVersion5Pay roleId=" + cpinfoRoleId + ",gamesn=" + cpinfoGamesn + ",selfchannel=" + selfchannel);
					}
				} else {
					if(cpinfos.length < 5){
						logger.error("MessageHandler.doVersion5Pay cpinfos=" + cpinfos.toString() + ",length=" + cpinfos.length);
						sendFailure(sc);
						return;
					} else if(cpinfos.length == 5){
						//String cpinfoServerId = cpinfos[0];
						String cpinfoSelfChannel = cpinfos[1];
						selfchannel = cpinfoSelfChannel;
						String cpinfoRoleId = cpinfos[2];
						//String cpinfoIp = cpinfos[3];
						//String cpinfoDeviceId = cpinfos[4];
						cpinfoGamesn = "-1";
						logger.info("MessageHandler.doVersion5Pay roleId=" + cpinfoRoleId + ",gamesn=" + cpinfoGamesn + ",selfchannel=" + selfchannel);
					} else {
						//String cpinfoServerId = cpinfos[0];
						String cpinfoSelfChannel = cpinfos[1];
						selfchannel = cpinfoSelfChannel;
						String cpinfoRoleId = cpinfos[2];
						//String cpinfoIp = cpinfos[3];
						//String cpinfoDeviceId = cpinfos[4];
						cpinfoGamesn = cpinfos[cpinfos.length - 1];
						logger.info("MessageHandler.doVersion5Pay roleId=" + cpinfoRoleId + ",gamesn=" + cpinfoGamesn + ",selfchannel=" + selfchannel);
					}
				}	
				String selfchannel0 = selfchannel.substring(0,1);
				//因为是混服，增加一个安卓和ios的渠道区分，同服但是帐号不互通。
				String account = strPlatformId + "@@" + strChannel + "@" + selfchannel0;
				logger.info("MessageHandler.doVersion5Pay account=" + account);
				new PPayOrderResponse(jsonObject.toString(), iVersion, iServerId, lRoleId, cpinfoGamesn).submit();
				sendSuccess(sc, strOrderId);
			} catch (Exception e) {
				sendFailure(sc);
			}
		}
	}
	
	private static void doPay(Message revMsg, SocketChannel sc) {
		try {
			short iVersion = revMsg.readShort();
			if(iVersion == 3) {
				doVersion3Pay(revMsg, sc, iVersion);
			} else if(iVersion == 5) {
				doVersion5Pay(revMsg, sc, iVersion);
			} else {
				logger.error("MessageHandler.handleMessage:doPay.version=" + iVersion + ",未接入的处理版本号！");
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			logger.error("MessageHandler.handleMessage:doPay.处理异常e=" + e);
			sendFailure(sc);
		}
	}
	
	private static void sendSuccess(SocketChannel sc, String strOrderId) {
		try {
			Message msgOut = new Message((short)2);
			msgOut.setMessageNum((short)4);
			msgOut.writeString(strOrderId);
			msgOut.writeShort((short)1);
			ByteBuffer buf = msgOut.toSend();
			sc.write(buf);
		} catch (IOException e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.MessageHandler.sendSuccess - 发送成功响应");
		} catch (ArrayIndexOutOfBoundsException e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.MessageHandler.sendSuccess - 数组越界");
		}
	}
	
	private static void sendFailure(SocketChannel sc) {
		try {
			Message msgOut = new Message((short)2);
			msgOut.setMessageNum((short)4);
			msgOut.writeString("");
			msgOut.writeShort((short)2);
			ByteBuffer buf = msgOut.toSend();
			sc.write(buf);
		} catch (IOException e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.MessageHandler.sendFailure - 发送失败响应");
		} catch (ArrayIndexOutOfBoundsException e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.MessageHandler.sendFailure - 数组越界");
		}
	}
}
