# OPPO Watch X2 (OWW251) TWRP 设备树 — 修复版

原始设备树由 twrpdtgen 从 `recovery.img` 生成（本仓库即升级后的版本）。
本版针对实机反馈的问题逐条修好了配置，全部数值来自真机 GPT / super 元数据 /
原厂 `fstab.qcom`，不再使用生成器占位值。

**/data 默认不加密**，所以本版不编 crypto、不带 keymaster/gatekeeper blobs，`/data` 直接挂载。

| 问题 | 根因 | 本版修复 |
| --- | --- | --- |
| 所有分区挂不上 | ① 动态分区没开 `TW_INCLUDE_LOGICAL`，`/dev/block/mapper/*` 根本没建；② fstab 里 logical 分区的设备名写的是 `system` 这种裸名；③ 写了不存在的 `odm`、SD 卡；④ `/dev/block/by-name` 无人创建 | BoardConfig 开 `TW_INCLUDE_LOGICAL`；重写 `twrp.fstab`（`/dev/block/mapper/<name>` + `logical`）；删掉 odm/sdcard；init rc 里显式建 `bootdevice` 与 `by-name` 两个链接 |
| /system、/vendor 报 Invalid argument | 这四个镜像带 ext4 `shared_blocks` 特性，内核只许只读挂载；TWRP 默认按读写挂 → EINVAL | `twrp.fstab` 给四个 logical 分区加 `fsflags=ro`；真实系统在 `/system_root/system`（system-as-root 布局） |
| fastbootd 不正常 | `TW_INCLUDE_FASTBOOTD` 未开，Reboot 菜单没有 Fastboot 入口，TWRP 也不会设 `sys.usb.config=fastboot`；另外 fastbootd 需要 fs_mgr 格式的 `/etc/recovery.fstab` 和 `/dev/block/by-name/super` | 开 `TW_INCLUDE_FASTBOOTD`；`recovery.fstab` 用 fs_mgr 格式（logical 分区 + super）；init rc 建 `by-name` 链接；cmdline 补 `androidboot.dynamic_partitions=true` |
| 进不了 EDL | `TW_HAS_EDL_MODE` 未开，`tw_edl_mode=0`，主题里 EDL 按钮直接被隐藏 | 开 `TW_HAS_EDL_MODE`（同时开 `TW_HAS_DOWNLOAD_MODE` 给 Download）；提供 `/system/bin/rebootedl.sh` 兜底 |
| adb / MTP 都用不了 | ① ABL 不传 `androidboot.usbcontroller`（abl 里确实没有这一项）→ `ro.boot.usbcontroller` 空 → `sys.usb.controller` 没人设 → TWRP 所有 `write UDC ${sys.usb.controller}` 写空值失败，gadget 从未绑定；② TWRP 自带 `init.recovery.usb.rc` 只有 legacy `android_usb` 写法，没有 `ffs.mtp` 的 configfs 规则，MTP 起不来 | `sys.usb.controller` 在 init rc 里写死为 `4e00000.dwc3`（DT: `dwc3@4e00000`）；`TW_EXCLUDE_DEFAULT_USB_INIT := true` 并换成设备树自己的 configfs USB rc（adb / mtp / mtp,adb / fastboot / sideload 全套） |

详见 `docs/04_修复说明.md`。

## 相对原树的改动

新增：

```
recovery/root/init.recovery.usb.rc
recovery/root/system/etc/twrp.fstab
recovery/root/system/bin/rebootedl.sh
.github/workflows/build.yml
```

改写：`BoardConfig.mk`（分区尺寸/组名/内核头/TW_* 开关）、`recovery.fstab`、
`init.recovery.qcom.rc`、`AndroidProducts.mk`、`twrp_OWW251.mk`、`device.mk`。

删除：`omni_OWW251.mk`（AndroidProducts 本来也没引用它）。

## 目录结构

```
.
├── BoardConfig.mk                  # 分区尺寸、内核头、TW_* 开关
├── device.mk / twrp_OWW251.mk      # product 配置
├── recovery/root/                  # 整棵树拷进 recovery ramdisk 根
│   ├── init.recovery.qcom.rc       # /dev/block 链接、UDC 名、可执行位兜底
│   ├── init.recovery.usb.rc        # configfs gadget：adb / mtp,adb / fastboot / sideload
│   ├── system/etc/twrp.fstab       # TWRP 挂载表（v2 格式）
│   ├── system/etc/recovery.fstab   # init + fastbootd 用（fs_mgr 格式）
│   └── system/bin/rebootedl.sh
├── prebuilt/                       # 原机 zImage / dtb / recovery_dtbo
├── docs/                           # 镜像解析证据 + 修复说明
└── .github/workflows/build.yml     # TWRP 11 minimal manifest 云编译
```

## 编译

推到 GitHub 后跑 **Build TWRP (OWW251)** 工作流，产物是
`out/target/product/OWW251/recovery.img`。

分支用 **twrp-11**：你之前能开机的那版就是 `twrp_OWW251-eng 11 RQ1A.210205.004`，
12.1 在这台机器上会卡在 TWRP 启动画面。

```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
repo sync -j8
mkdir -p device/oppo && cp -a <本仓库> device/oppo/OWW251
source build/envsetup.sh && lunch twrp_OWW251-eng && m recoveryimage
```

> 用的是 mkbootimg 直出（header v2 + dtb + recovery_dtbo，地址与原厂一致），
> 不需要再拿 stock 头二次打包。

## 刷入

```sh
adb push recovery.img /tmp/
adb shell dd if=/tmp/recovery.img of=/dev/block/bootdevice/by-name/recovery
adb reboot recovery
```

（TWRP 的 adbd 默认就是 root，不需要 su。）
回滚原厂 recovery：用 OFP 里的 `recovery.img` 同样 dd 回去，或走 EDL + GeekFlashTool。

## 菜单项没出现时的替代入口

* EDL：TWRP 终端里执行 `rebootedl.sh`，或 PC 上 `adb reboot edl`。
* fastbootd：PC 上 `adb reboot fastboot`（写入 boot-fastboot BCB，ABL 会带 `--fastboot` 启动 recovery）。
* 挂载：TWRP 终端里 `ls /dev/block/mapper` 看 dm 设备是否建出来。

## 仍需实机确认

1. **触摸**：`TW_INPUT_BLACKLIST := "hbtp_vm"` 沿用原树，若触摸无响应需 `getevent -p` 换设备名。
2. **亮度**：`TW_BRIGHTNESS_PATH` 用的是 `/sys/class/backlight/panel0-backlight/brightness`，
   与 stock init 写的路径一致。
