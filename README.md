# ofm-picker

用于 OFM 的模型测试以及修改配置。

一个**单文件 HTML**，用来挑选和测试 [Our Free Model](https://github.com/Ebony-Vinyl/dsh-our-free-model)（OFM）本地网关上的模型，并把选中的模型写进 DSH 的 `cordis.patch.yml`。

不需要 npm、不需要构建、不需要服务器 —— **双击 HTML 就能用**。

## 它解决什么问题

OFM 桌面端把几百个模型聚合到一个本地 OpenAI 兼容网关（默认 `http://127.0.0.1:18900/v1`）。
要让某个模型在 DSH 里可选，你得手动编辑 `cordis.patch.yml`，手写一长串 `id` / `name` /
`contextWindow` / `maxTokens` / `reasoningEfforts` —— 很麻烦，而且：

- 不知道哪个模型**此刻真的能连通**（免费模型波动很大，几分钟前失败、几分钟后就通是常事）
- 不知道模型**支不支持思考强度**（漏写 `reasoningEfforts`，DSH 选择器里就没有等级可选）
- 手写 YAML 容易把其他 provider、权限预设、MCP 配置一起改坏

这个页面把这些都自动化了。

## 三步用法

1. **连接**：填 OFM 的 `forwardKey`（在 `%USERPROFILE%\.our-free-model\settings.json` 里，
   或 OFM 桌面端 → 设置 → 本地网关）。Key 只存在你自己浏览器的 localStorage 里。
2. **挑**：左右两个列表 —— 左边全部模型，右边 DSH 配置里的。点左边某行加入配置，点右边某行移出。
3. **写**：点「应用到 DSH 配置」，确认明细后落盘。重启 DSH 生效。

## 功能

| 功能 | 说明 |
|---|---|
| **穿梭框** | 左=全部模型，右=配置里的。点行即增删，右侧就是最终清单 |
| **模型测试** | 按 DSH 真实协议（`POST /v1/responses`）发最小请求，判连通/仅思考/超时/凭证失效/地区受限/EOL |
| **批量测试** | 测全部 / 只测免费 / 只测右侧 / 测左侧勾选 / 测右侧勾选 |
| **深度复核** | 加大输出预算，专治「HTTP 200 但只有思考没有正文」 |
| **一键搬运** | 「把所有连通的加入配置」——测完直接搬 |
| **视觉编码** | 渠道角标（右上角色块）、模型族色条（底部 3px）、EAC 协付特殊标记（紫竖线+斜纹） |
| **计费识别** | 从 OFM 显示名解析 `x0.79` / `免费`，解不出记为「未知」不猜测 |
| **思考等级** | 从 OFM `/v1/models` 的 `reasoning.efforts` 映射为 DSH 的 `reasoningEfforts`；缺失时按型号族推断 |
| **安全写入** | 行级区间替换，只动 `ofm.models` 一段；写前校验 + 自动备份 + 并发检测 |
| **协议测试** | 对比 responses / chat completions / anthropic messages 三种协议的工具调用能力 |

## 关于「配置文件路径」

页面**不假设你的 DSH 装在哪个 profile**。三种方式任选：

1. **服务直连（最省事）**：如果 [dsh-model-lab](https://github.com/Ebony-Vinyl/dsh-our-free-model)
   的服务在跑，页面自动连它读写配置，全程免选文件。
2. **选 profile**：下拉框选 `web` / `desktop` / `headless` / `headless_ofm` / `headless_ofm_ns`。
3. **手动选文件**：点「手动选择文件」选一次 `cordis.patch.yml`，浏览器会记住（File System Access API）。

> ⚠ 服务直连用的是**服务端那台机器的路径**（`~/.dsh/profiles/web/cordis.patch.yml`）。
> 如果你的 DSH 用的不是 `web` profile，请改用「手动选择文件」或换 profile —— 选手后页面会锁定手动文件，不再走服务端。

## 运行要求

- **Edge 或 Chrome**（需要 File System Access API；隐身模式不行）
- OFM 桌面端在跑（提供 `http://127.0.0.1:18900/v1`）
- 要写配置的话：要么 dsh-model-lab 服务在跑，要么允许选一次文件

## 已知边界

- 只测「能不能回一个 token」，**不测长任务稳定性**。探针 2 秒过的模型，真实任务可能 300 秒后挂。
- 免费模型波动大，一次失败不代表坏了 —— 建议写入前再测一次。
- 单条默认超时 15 秒（可调 3~600）。已知 `qoder/qfmodel`、`deepseek-ai/deepseek-v4.1-flash`
  这类要 90 秒左右才会被这个默认值判超时。

## 安全说明

- **Key 不出本机**：只存 localStorage，只发往 `127.0.0.1` 的 OFM 网关。
- **写文件前必确认**：弹窗列出新增/移除明细。
- **只改一段**：写入是行级区间替换，同文件里的其他 provider、权限预设、MCP 配置原样保留。
- **自动备份**：服务直连模式下，服务端每次写入前备份；手动模式下请自行点「导出勾选项」留底。

## 开发

自检（48 项断言，纯函数，无网络）：

```bash
# 需要 node 和一个能收 POST 的本地服务（用于回收自检结果）
node -e "…"   # 见 ofm-picker.html 里的 runSelfTest()
```

页面里的 `window.__ofm` 是给外部驱动/自检用的只读出口。

## License

MIT

