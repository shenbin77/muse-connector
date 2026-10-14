# Muse 连接助手

让 Muse（AI 助手）安全地访问你的 Windows 本地电脑。

## 这是什么

一个轻量级的本地 HTTP 网关，运行在你的 Windows 电脑上。Muse 通过它可以：
- 读写指定目录下的文件
- 执行白名单内的脚本（git、Python、PowerShell）
- 全程 Token 鉴权 + 路径隔离 + 操作日志

**不是**向日葵/TeamViewer 那种人控人的远程桌面，而是**专门给 AI 开的本地接入通道**。

## 安全设计

- **Token 鉴权**：所有接口要求 `X-Token` 请求头，首次运行自动生成
- **路径隔离**：文件操作限定在配置目录内，防目录穿越
- **命令白名单**：只允许 git / 站内 Python 脚本 / 站内 PowerShell 脚本
- **IP 限制**：默认只应答本机 + Tailscale 网段
- **审计日志**：所有请求记入 `agent.log`
- **无残留**：关闭即停止，不写注册表（托盘版除外）

## 快速开始

### 要求

- Windows 10+
- Python 3.8+（勾选 Add to PATH）

### 安装

1. 下载本仓库，解压到比如 `D:\MuseAgent\`
2. 双击 `一键启动助手.bat`
3. 窗口显示 Token，**复制发给你的 Muse**
4. 保持窗口开着（或使用托盘版后台运行）

### 远程访问（可选）- 双模式

**快速隧道模式**（默认，零配置）：
直接双击 `一键启动助手.bat`，自动使用 cloudflared 快速隧道。
- 优点：无需注册、无需配置，开箱即用
- 缺点：URL 每次随机（形如 `https://xxx.trycloudflare.com`），重启后需重新发给 Muse

**固定域名模式**（进阶）：
1. 注册 Cloudflare 账号，创建隧道：`cloudflared tunnel create <名字>`
2. 复制 `src/cloudflared-winagent.yml.example` 为 `src/cloudflared-winagent.yml`
3. 填入你的隧道 ID 和域名
4. 双击 `一键启动助手.bat`，自动检测到配置文件并使用固定域名

### 远程访问（可选）

如果你需要从外网访问：

1. 安装 [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)
2. 复制 `src/cloudflared-winagent.yml.example` 为 `cloudflared-winagent.yml`，填入你的隧道信息
3. 运行 `tunnel.bat`

## 文件说明

| 文件 | 说明 |
|------|------|
| `src/win_agent.py` | 核心 HTTP 服务 |
| `src/tray_app.py` | 系统托盘托管程序（后台运行） |
| `src/win_agent_start.bat` | 启动脚本（显示 Token） |
| `src/一键启动助手.bat` | 一键启动（含隧道） |
| `src/tunnel.bat` | 单独启动 cloudflared 隧道 |
| `src/停止助手.bat` | 停止所有服务 |
| `src/cloudflared-winagent.yml.example` | 隧道配置模板 |

## API 接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/health` | GET | 健康检查（无需鉴权） |
| `/api/ls?path=` | GET | 列目录 |
| `/api/cat?path=` | GET | 读文件 |
| `/api/put?path=` | POST | 写文件 |
| `/api/exec` | POST | 执行白名单命令 |

所有接口（除 `/api/health`）需要在 Header 中带 `X-Token`。

## 开机自启

托盘版已支持开机自启。或手动将 `一键启动助手.bat` 的快捷方式放入：
`shell:startup`

## 许可证

MIT License - 见 [LICENSE](LICENSE)

## 免责

本工具授予 AI 对你电脑的**受限**访问权限。请：
- 妥善保管 Token，泄露后删除 `token.txt` 重启即轮换
- 不要在不可信的网络暴露端口
- 定期查看 `agent.log` 审计操作
