//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import org.apache.log4j.Logger;
import xtable.Auuserinfo;

public class SimpleWebGMManager {
    private static final Logger SECURITY_LOG = Logger.getLogger("GM_SECURITY");
    private static final Logger logger = Logger.getLogger("GMCOMMAND");
    private static final int WEB_BACKEND_USER_ID = 4096;
    private static Set<String> WEB_SERVER_IPS = new HashSet();
    private static final Set<String> WEB_SAFE_COMMANDS;
    private static final Set<String> DANGEROUS_COMMANDS;

    private static void loadServerIPFromConfig() {
        try {
            InputStream is = SimpleWebGMManager.class.getResourceAsStream("/properties/sys.properties");
            if (is == null) {
                File propFile = new File("properties/sys.properties");
                if (propFile.exists()) {
                    is = new FileInputStream(propFile);
                }
            }

            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                is.close();
                String serverIP = props.getProperty("sys.gm.web.server_ip");
                if (serverIP != null && !serverIP.trim().isEmpty()) {
                    WEB_SERVER_IPS.add(serverIP.trim());
                    SECURITY_LOG.info("从配置文件加载Web服务器IP: " + serverIP);
                } else {
                    SECURITY_LOG.warn("配置文件中未找到sys.gm.web.server_ip配置");
                }
            } else {
                SECURITY_LOG.warn("未找到sys.properties配置文件");
            }
        } catch (Exception e) {
            SECURITY_LOG.error("读取配置文件异常", e);
        }

    }

    public static boolean hasPermission(int userId, long roleId, String command, String clientIP) {
        try {
            SECURITY_LOG.info(String.format("GM权限检查: userId=%d, roleId=%d, IP=%s, 命令=%s", userId, roleId, clientIP, command));
            return userId == 4096 ? validateWebBackendAccess(command, clientIP) : validateNormalGMAccess(userId, roleId, command);
        } catch (Exception e) {
            SECURITY_LOG.error("GM权限验证异常", e);
            return false;
        }
    }

    private static boolean validateWebBackendAccess(String command, String clientIP) {
        if (!WEB_SERVER_IPS.contains(clientIP)) {
            SECURITY_LOG.warn("Web后台GM被拒绝 - IP不在白名单: " + clientIP);
            return false;
        } else if (DANGEROUS_COMMANDS.contains(command.toLowerCase())) {
            SECURITY_LOG.warn("Web后台危险GM命令被拒绝: " + command);
            return false;
        } else if (!WEB_SAFE_COMMANDS.contains(command.toLowerCase())) {
            SECURITY_LOG.warn("Web后台GM命令不在白名单: " + command);
            return false;
        } else if (hasCommandInjection(command)) {
            SECURITY_LOG.error("检测到命令注入攻击: " + command);
            return false;
        } else {
            SECURITY_LOG.info("Web后台GM命令执行许可: " + command + ", IP: " + clientIP);
            return true;
        }
    }

    private static boolean validateNormalGMAccess(int userId, long roleId, String command) {
        try {
            Integer gmLevel = Auuserinfo.selectBlisgm(userId);
            if (gmLevel != null && gmLevel >= 1) {
                SECURITY_LOG.info("普通GM命令执行许可: userId=" + userId + ", gmLevel=" + gmLevel + ", 命令=" + command);
                return true;
            } else {
                SECURITY_LOG.warn("普通GM用户权限不足: userId=" + userId);
                return false;
            }
        } catch (Exception e) {
            SECURITY_LOG.error("普通GM权限验证异常", e);
            return false;
        }
    }

    private static boolean hasCommandInjection(String command) {
        if (command == null) {
            return true;
        } else {
            String[] dangerousPatterns = new String[]{"../", "./", "rm ", "del ", "format", "shutdown", "reboot", "$(", "${", "`", "&", "|", ";", "&&", "||", ">", "<", "exec", "system", "eval", "script"};
            String lowerCommand = command.toLowerCase();

            for(String pattern : dangerousPatterns) {
                if (lowerCommand.contains(pattern)) {
                    return true;
                }
            }

            return command.length() > 200;
        }
    }

    public static boolean addWebServerIP(String ip) {
        if (ip != null && !ip.trim().isEmpty()) {
            boolean added = WEB_SERVER_IPS.add(ip.trim());
            if (added) {
                SECURITY_LOG.info("添加新的Web服务器IP到白名单: " + ip);
            }

            return added;
        } else {
            return false;
        }
    }

    public static boolean isWebServerIP(String ip) {
        return WEB_SERVER_IPS.contains(ip);
    }

    public static Map<String, Object> getConfigInfo() {
        Map<String, Object> config = new HashMap();
        config.put("webBackendUserId", 4096);
        config.put("webServerIPs", new HashSet(WEB_SERVER_IPS));
        config.put("safeCommandsCount", WEB_SAFE_COMMANDS.size());
        config.put("dangerousCommandsCount", DANGEROUS_COMMANDS.size());
        return config;
    }

    public static void reloadConfig() {
        WEB_SERVER_IPS.clear();
        WEB_SERVER_IPS.add("127.0.0.1");
        WEB_SERVER_IPS.add("localhost");
        loadServerIPFromConfig();
        SECURITY_LOG.info("Web后台GM配置已重新加载");
    }

    static {
        WEB_SERVER_IPS.add("127.0.0.1");
        WEB_SERVER_IPS.add("localhost");
        loadServerIPFromConfig();
        WEB_SAFE_COMMANDS = new HashSet(Arrays.asList("additem", "addgold", "addlevel", "addqian", "addvipexp", "setvip", "forbid", "unforbid", "kick", "mail", "post", "addpet", "addhyd", "addlife", "addbanggong", "addfactionmoney", "nonvoice", "unnonvoice", "clearbag", "hideme", "showme", "battle", "addtitle", "deltitle", "cangbatou", "addpetskill", "delpetskill", "addpetexp", "changebindtel", "award", "offlinetime", "bpgx", "yaofangrefresh", "checkcode", "coquest", "createrole", "baitantimeclear", "dismissguild", "setdays", "mailbycond", "zmd", "readpackandpet", "setpetvalue", "subfushi"));
        DANGEROUS_COMMANDS = new HashSet(Arrays.asList("stopgs", "reload", "destroyzone", "clearalldata", "deleteall", "shutdown", "restart", "reset", "format", "drop", "truncate"));
    }
}
