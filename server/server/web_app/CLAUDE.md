# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the web management interface for the MMORPG game server "梦幻诛仙" (gsxdb-jm). It's built with ThinkPHP 8 multi-app architecture and integrates with the game server via JMX/GM commands.

**Key Relationship**: This web_app is part of the larger gsxdb-jm project. The Java game server source is at `../../..` (project root), while this directory handles the web admin interface, player portal, payment processing, and GM operations.

## Architecture

### Multi-App Structure
```
app/
├── admin/       # Management backend (type=1 users)
├── agent/       # Agent backend (type=2 users) - manages players/withdrawals
├── player/      # Player portal - profile, orders, transfer, CDK
├── login/       # Legacy auth entry (compatible with player/)
├── api/         # Payment callbacks, voice, compatibility layer
├── index/       # Frontend activity/CDK pages
├── sdk/         # SDK integration shell
├── gm/          # JMX/GM command execution (Gm.php)
├── model/       # ThinkPHP models
├── service/     # Business logic services
├── middleware/  # Global middleware (auth, security, permissions)
└── controller/  # Shared controllers
```

### Core Components

**JMX/GM Integration** (`app/gm/Gm.php`):
- Executes game server commands via `jmxc/jmxc.jar`
- Requires JMX auth credentials from `config/security.php` or `app/admin/security_config.php`
- All commands must include: username, password, serverip, port, userId, roleId, optional token
- Key methods: `addsuperitem`, `mail`, `addqian`, `kick`, `forbid`, etc.

**Authentication**:
- `admin`/`agent`: Session-based with token verification via `Check` middleware
- `player`: Token-based auth with HMAC signatures via `PlayerAuth` middleware
- Two auth systems coexist - always verify which one applies

**Permission System** (`config/permission.php`):
- Fine-grained `PermissionGuard` middleware for admin/agent
- Format: `app.controller.action => [type]`
- Types: 1=admin, 2=agent

## Build & Test Commands

```bash
# Verify PHP syntax
php -l public/index.php

# Check composer dependencies
composer check

# Run smoke test placeholder
composer test:smoke

# Full check
composer check
```

## Key Configuration Files

| File | Purpose |
|------|---------|
| `config/database.php` | MySQL connection (uses env vars) |
| `config/security.php` | JMX auth, XSS/CSRF, session security |
| `config/permission.php` | Fine-grained permission rules |
| `config/player.php` | Player auth, signature settings |
| `config/route.php` | URL routing, middleware registration |
| `composer.json` | Dependencies and scripts |

## Critical Security Points

1. **JMX Authentication**: Required for GM commands; misconfiguration blocks all game server operations
2. **Secret Keys**: `OP_SECRET_SALT` must be configured for player auth operations
3. **Payment Callbacks**: Protected by replay prevention (`timestamp + nonce`) and idempotency locks
4. **SQL Injection**: Use ThinkPHP query builder; avoid raw SQL concatenation
5. **Input Validation**: `BaseController::validateInput()` strips dangerous characters
6. **CSRF**: Token required for state-changing operations (see `CsrfTrait`)

## GM Command Patterns

When adding new GM operations:

1. Method in `app/gm/Gm.php` must call `safeExecGmCommand($data, $gmCommand)`
2. Command format: `command arg1 arg2...` (no extra quotes - `safeExecGmCommand` handles escaping)
3. Required `$data` keys: `serverip`, `gmport`, `playerid`
4. Optional `$data` keys: `userid`, `gm_userid`
5. Always include roleId as third parameter for player-targeted commands like `addsuperitem`

## Common Tasks

**Adding a new admin/agent page**:
1. Create controller in `app/admin/controller/` or `app/agent/controller/`
2. Create view in `app/{app}/view/{controller}/`
3. Add permission rule to `config/permission.php` if access-restricted
4. Protected by `Check` middleware automatically

**Adding a new player portal feature**:
1. Create controller in `app/player/controller/`
2. Create view in `app/player/view/`
3. Add auth/safety middleware in `app/player/middleware.php`
4. Use `AuthService` for session management

**Adding GM command support**:
1. Add method to `app/gm/Gm.php` following existing patterns
2. Call via `$Game = new \app\gm\Gm(); $Game->yourMethod($data);`
3. Ensure JMX auth is configured

## Database Access

- Use ThinkPHP Model: `new \app\model\TableName()`
- Query Builder: `Db::table('tablename')->where(...)->select()`
- For complex queries, use query builder with parameter binding

## Session Handling

- **Admin/Agent**: Uses `player_admin_username`, `player_admin_token` (new) or `username_1/2`, `auth_token_1/2` (legacy)
- **Player**: Uses `id`, `serverid`, `auth_token` managed by `AuthService`
- Session store: file (configurable in `config/session.php`)

## Error Handling

All unhandled exceptions go to `app/ExceptionHandle.php`. Log context:
- Use `Log::info()` for audit trails
- Use `Log::error()` for failures (include `$data` for debugging)
- For GM commands, sanitize tokens/passwords before logging

## Integration Points

**With Java Game Server**:
- GM commands via `jmxc.jar` at `{root}/jmxc/jmxc.jar`
- Game server config: `sys.properties` (JMX credentials must match)
- Protocol: command-line args passed to Java JMX client

**Payment**:
- Callbacks handled in `app/api/controller/Pay.php`
- Idempotency via Redis: `pay_callback_lock:{orderid}`
- Order state machine in `UserOrder` model

**Transfer/Role Migration**:
- Service: `app/service/TransferExecutionService.php`
- Admin review: `app/admin/controller/Transfer.php`
- Player submission: `app/player/controller/Transfer.php`
