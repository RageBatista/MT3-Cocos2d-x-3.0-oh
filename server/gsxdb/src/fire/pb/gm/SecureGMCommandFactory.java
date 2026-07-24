//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
import org.apache.log4j.Logger;

public class SecureGMCommandFactory {
    private static final Logger logger = Logger.getLogger("GM_SECURITY");
    private static final Logger GM_LOGGER = Logger.getLogger("GMCOMMAND");
    private static final Map<Integer, Set<String>> USER_COMMAND_PERMISSIONS = new ConcurrentHashMap();
    private static final String CONFIG_FILE = "gm_permissions.properties";
    private static final ScheduledExecutorService configScheduler = Executors.newSingleThreadScheduledExecutor((r) -> {
        Thread t = new Thread(r, "GM-Config-Reloader");
        t.setDaemon(true);
        return t;
    });
    private static final Set<String> GLOBALLY_FORBIDDEN_COMMANDS = new HashSet(Arrays.asList("stopgs", "shutdown", "restart", "destroyzone", "clearalldata", "deleteall", "format", "drop", "truncate", "rm", "del", "exec", "system", "eval"));

    public static GMCommand createSecureGMCommand(int userId, String commandName) {
        if (commandName != null && !commandName.trim().isEmpty()) {
            String cmd = commandName.trim().toLowerCase();
            if (GLOBALLY_FORBIDDEN_COMMANDS.contains(cmd)) {
                String msg = String.format("危险GM指令被全局禁用: %s", cmd);
                logger.warn(String.format("用户[%d]尝试执行危险指令[%s]", userId, cmd));
                throw new SecurityException(msg);
            } else if (!hasCommandPermission(userId, cmd)) {
                String msg = String.format("用户[%d]无权限执行GM指令[%s]", userId, cmd);
                logger.warn(msg);
                throw new SecurityException("权限验证失败：无此指令执行权限");
            } else if (!isValidCommandName(cmd)) {
                String msg = String.format("非法GM指令名称格式: %s", cmd);
                logger.error(msg);
                throw new SecurityException("指令名称格式非法");
            } else {
                try {
                    return loadGMCommandSecurely(cmd, userId);
                } catch (Exception e) {
                    logger.error(String.format("用户[%d]创建GM指令[%s]失败", userId, cmd), e);
                    throw new RuntimeException("GM指令创建失败: " + e.getMessage(), e);
                }
            }
        } else {
            throw new IllegalArgumentException("GM指令名称不能为空");
        }
    }

    private static boolean hasCommandPermission(int userId, String commandName) {
        Set<String> userCommands = (Set)USER_COMMAND_PERMISSIONS.get(userId);
        if (userCommands == null) {
            userCommands = (Set)USER_COMMAND_PERMISSIONS.get(-1);
        }

        return userCommands != null && userCommands.contains(commandName.toLowerCase());
    }

    private static boolean isValidCommandName(String commandName) {
        return commandName != null && commandName.matches("^[a-zA-Z][a-zA-Z0-9_]*$") && commandName.length() >= 2 && commandName.length() <= 50;
    }

    private static GMCommand loadGMCommandSecurely(String commandName, int userId) {
        try {
            String className = "fire.pb.gm.GM_" + commandName;
            Class<?> clazz = Class.forName(className);
            if (!clazz.getPackage().getName().equals("fire.pb.gm")) {
                throw new SecurityException("GM指令类包路径非法: " + clazz.getPackage().getName());
            } else if (!GMCommand.class.isAssignableFrom(clazz)) {
                throw new SecurityException("非法GM指令类，必须继承GMCommand: " + className);
            } else {
                GMCommand command = (GMCommand)clazz.newInstance();
                GM_LOGGER.info(String.format("安全创建GM指令: 用户[%d] 指令[%s]", userId, commandName));
                return command;
            }
        } catch (ClassNotFoundException var5) {
            throw new IllegalArgumentException("GM指令不存在: " + commandName);
        } catch (IllegalAccessException | InstantiationException e) {
            throw new RuntimeException("GM指令实例化失败: " + commandName, e);
        } catch (SecurityException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("未知错误: " + e.getMessage(), e);
        }
    }

    private static void loadPermissionConfiguration() {
        try {
            Properties props = new Properties();
            boolean configLoaded = false;
            String[] configPaths = new String[]{"properties/gm_permissions.properties", "config/gm_permissions.properties", "gm_permissions.properties", "../config/gm_permissions.properties", "cenots7.6-server/config/gm_permissions.properties"};

            for(String path : configPaths) {
                File configFile = new File(path);
                if (configFile.exists() && configFile.canRead()) {
                    try (FileInputStream fis = new FileInputStream(configFile)) {
                        props.load(fis);
                        configLoaded = true;
                        logger.info("成功加载GM权限配置文件: " + configFile.getAbsolutePath());
                        break;
                    }
                }
            }

            if (!configLoaded) {
                logger.warn("未找到GM权限配置文件，使用默认权限配置");
                loadDefaultPermissions();
                return;
            }

            parsePermissionConfiguration(props);
        } catch (Exception e) {
            logger.error("加载GM权限配置失败，使用默认配置", e);
            loadDefaultPermissions();
        }

    }

    private static void parsePermissionConfiguration(Properties props) {
        USER_COMMAND_PERMISSIONS.clear();
        String webCommands = props.getProperty("web.backend.commands", "");
        if (!webCommands.isEmpty()) {
            Set<String> commands = (Set)Arrays.stream(webCommands.split(",")).map(String::trim).map(String::toLowerCase).filter((cmd) -> !cmd.isEmpty()).collect(Collectors.toSet());
            USER_COMMAND_PERMISSIONS.put(4096, commands);
            logger.info("Web后台权限加载完成，支持" + commands.size() + "个指令");
        }

        String normalCommands = props.getProperty("normal.gm.commands", "");
        if (!normalCommands.isEmpty()) {
            Set<String> commands = (Set)Arrays.stream(normalCommands.split(",")).map(String::trim).map(String::toLowerCase).filter((cmd) -> !cmd.isEmpty()).collect(Collectors.toSet());
            USER_COMMAND_PERMISSIONS.put(-1, commands);
            logger.info("普通GM权限加载完成，支持" + commands.size() + "个指令");
        }

        String advancedCommands = props.getProperty("advanced.gm.commands", "");
        if (!advancedCommands.isEmpty()) {
            Set<String> commands = (Set)Arrays.stream(advancedCommands.split(",")).map(String::trim).map(String::toLowerCase).filter((cmd) -> !cmd.isEmpty()).collect(Collectors.toSet());
            USER_COMMAND_PERMISSIONS.put(-2, commands);
            logger.info("高级GM权限加载完成，支持" + commands.size() + "个指令");
        }

    }

    private static void loadDefaultPermissions() {
        USER_COMMAND_PERMISSIONS.clear();
        Set<String> webDefault = new HashSet(Arrays.asList("additem", "addgold", "addlevel", "addqian", "addvipexp", "setvip", "forbid", "unforbid", "kick", "mail", "post", "addpet", "addhyd", "addlife", "addbanggong", "addfactionmoney", "nonvoice", "unnonvoice", "clearbag", "hideme", "showme", "battle", "addtitle", "deltitle", "cangbatou", "addpetskill", "delpetskill", "addpetexp", "changebindtel", "award", "offlinetime", "bpgx", "yaofangrefresh", "checkcode", "coquest", "createrole", "baitantimeclear", "dismissguild", "setdays", "mailbycond", "zmd", "readpackandpet", "setpetvalue", "subfushi"));
        USER_COMMAND_PERMISSIONS.put(4096, webDefault);
        Set<String> normalDefault = new HashSet(webDefault);
        normalDefault.addAll(Arrays.asList("check", "query", "reload", "backup", "restore", "status"));
        USER_COMMAND_PERMISSIONS.put(-1, normalDefault);
        logger.info("使用默认GM权限配置加载完成");
    }

    public static Map<String, Object> getUserPermissionInfo(int userId) {
        Map<String, Object> info = new HashMap();
        Set<String> userCommands = (Set)USER_COMMAND_PERMISSIONS.get(userId);
        if (userCommands == null) {
            userCommands = (Set)USER_COMMAND_PERMISSIONS.get(-1);
            info.put("permissionType", "default");
        } else {
            info.put("permissionType", userId == 4096 ? "web_backend" : "specific");
        }

        info.put("userId", userId);
        info.put("commandCount", userCommands != null ? userCommands.size() : 0);
        info.put("commands", userCommands != null ? new ArrayList(userCommands) : Collections.emptyList());
        info.put("forbiddenCommands", GLOBALLY_FORBIDDEN_COMMANDS);
        return info;
    }

    public static boolean addUserCommandPermission(int userId, String commandName) {
        if (commandName != null && isValidCommandName(commandName)) {
            Set<String> userCommands = (Set)USER_COMMAND_PERMISSIONS.get(userId);
            if (userCommands == null) {
                userCommands = new HashSet();
                USER_COMMAND_PERMISSIONS.put(userId, userCommands);
            }

            boolean added = userCommands.add(commandName.toLowerCase());
            if (added) {
                logger.info(String.format("运行时添加用户[%d]GM权限: %s", userId, commandName));
            }

            return added;
        } else {
            return false;
        }
    }

    public static Map<String, Object> getSystemStats() {
        Map<String, Object> stats = new HashMap();
        stats.put("totalUsers", USER_COMMAND_PERMISSIONS.size());
        stats.put("webBackendCommandCount", ((Set)USER_COMMAND_PERMISSIONS.getOrDefault(4096, Collections.emptySet())).size());
        stats.put("defaultCommandCount", ((Set)USER_COMMAND_PERMISSIONS.getOrDefault(-1, Collections.emptySet())).size());
        stats.put("forbiddenCommandCount", GLOBALLY_FORBIDDEN_COMMANDS.size());
        stats.put("configReloadEnabled", true);
        return stats;
    }

    static {
        loadPermissionConfiguration();
        configScheduler.scheduleAtFixedRate(SecureGMCommandFactory::loadPermissionConfiguration, 60L, 60L, TimeUnit.SECONDS);
        logger.info("SecureGMCommandFactory初始化完成，支持配置热更新");
    }
}
