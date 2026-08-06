-- Role/bind chain quick check
-- Usage:
--   1) Open in MySQL client
--   2) Set @account to the target username
--   3) Execute all statements

SET @account = 'www123';

SELECT id, username, lastagent, platform, bidserver, login_ip
FROM user_account
WHERE username = @account;

SELECT r.roleid, r.name, r.level, r.userid, r.profession, r.createtime, r.lastlogintime
FROM role r
LEFT JOIN user_account u ON u.id = r.userid
WHERE u.username = @account
   OR r.userid = (SELECT id FROM user_account WHERE username = @account LIMIT 1)
ORDER BY r.roleid DESC;

SELECT b.id, b.userid, b.serverid, b.playerid, b.playername, b.charge, u.username
FROM user_bind b
LEFT JOIN user_account u ON u.id = b.userid
WHERE u.username = @account
   OR b.userid = (SELECT id FROM user_account WHERE username = @account LIMIT 1)
ORDER BY b.id DESC;

SELECT id, username, info, date, time, ip, city
FROM user_log
WHERE username = @account
ORDER BY id DESC
LIMIT 30;

SELECT id, username, ip, platform, status, created_at, remark
FROM player_login_log
WHERE username = @account
ORDER BY id DESC
LIMIT 30;
