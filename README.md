# OPPO Watch X2 (OWW251) TWRP 设备树 — 修复版

原始设备树由 twrpdtgen 从 `recovery.img` 生成（本仓库即升级后的版本）。
本版针对实机反馈的四个问题逐条修好了配置，全部数值来自真机 GPT / super 元数据 /
原厂 `fstab.qcom`，不再使用生成器占位值。

| 问题 | 根因 | 本版修复 |
| --- | --- | --- |
| 所有分区挂不上 | ① 动态分区没开 `TW_INCLUDE_LOGICAL`，`/dev/block/mapper/*` 根本没建；② fstab 里 logical 分区的设备名写的是 `system` 这种裸名；③ 写了不存在的 `odm`、SD 卡；④ `/dev/block/by-name` 无人创建（fastbootd 也依赖它） | BoardConfig 开 `TW_INCLUDE_LOGICAL`；重写 `twrp.fstab`（`/dev/block/mapper/<name>` + `logical`）；删掉 odm/sdcard；init rc 里显式建 `bootdevice` 与 `by-name` 两个链接 |
| /data 解不开 | 编译时 `TW_INCLUDE_CRYPTO` 是注释掉的（现镜像 binary 里有 `No crypto support was compiled into this build.`），且 ramdisk 里没有 vendor keymaster/gatekeeper，init 也不会启动它们 | 打开 `TW_INCLUDE_CRYPTO` + `TW_INCLUDE_CRYPTO_FBE` + `TW_INCLUDE_FBE_METADATA_DECRYPT`；从本机 vendor 提取 keymaster 4.0/4.1、gatekeeper 1.0 及依赖库；新增 `init.recovery.qcom_decrypt.rc` 启动 HAL |
| fastbootd 不正常 | `TW_INCLUDE_FASTBOOTD` 未开，Reboot 菜单没有 Fastboot 入口，TWRP 也不会设 `sys.usb.config=fastboot`；另外 fastbootd 需要 fs_mgr 格式的 `/etc/recovery.fstab` 和 `/dev/block/by-name/super` | 开 `TW_INCLUDE_FASTBOOTD`；`recovery.fstab` 用 fs_mgr 格式（logical 分区 + super）；init rc 建 `by-name` 链接；cmdline 补 `androidboot.dynamic_partitions=true` |
| 进不了 EDL | `TW_HAS_EDL_MODE` 未开，`tw_edl_mode=0`，主题里 EDL 按钮直接被隐藏 | 开 `TW_HAS_EDL_MODE`（同时开 `TW_HAS_DOWNLOAD_MODE` 给 Download）；提供 `/system/bin/rebootedl.sh` 兜底 |
| adb / MTP 都用不了 | ① ABL 不传 `androidboot.usbcontroller`（abl 里确实没有这一项）→ `ro.boot.usbcontroller` 空 → `sys.usb.controller` 没人设 → TWRP 所有 `write UDC ${sys.usb.controller}` 写空值失败，gadget 从未绑定；② TWRP 自带 `init.recovery.usb.rc` 只有 legacy `android_usb` 写法，没有 `ffs.mtp` 的 configfs 规则，MTP 起不来 | `sys.usb.controller` 在 init rc 里写死为 `4e00000.dwc3`（DT: `dwc3@4e00000`）；`TW_EXCLUDE_DEFAULT_USB_INIT := true` 并换成设备树自己的 configfs USB rc（adb / mtp / mtp,adb / fastboot / sideload 全套） |

详见 `docs/04_修复说明.md`。

## 相对原树的改动

新增：

```
recovery/root/init.recovery.qcom_decrypt.rc
recovery/root/init.recovery.usb.rc
recovery/root/system/etc/twrp.fstab
recovery/root/system/bin/rebootedl.sh
recovery/root/system/bin/android.hardware.keymaster@{4.0,4.1}-service-qti
recovery/root/system/bin/android.hardware.gatekeeper@1.0-service-qti
recovery/root/system/lib/*.so + system/lib/hw/android.hardware.gatekeeper@1.0-impl-qti.so
recovery/root/vendor/etc/vintf/manifest.xml
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
│   ├── init.recovery.qcom.rc       # /dev/block 链接、TEE 权限、UDC 名、可执行位兜底
│   ├── init.recovery.qcom_decrypt.rc # servicemanager/keymaster/gatekeeper 启动
│   ├── init.recovery.usb.rc        # configfs gadget：adb / mtp,adb / fastboot / sideload
│   ├── system/etc/twrp.fstab       # TWRP 挂载表（v2 格式）
│   ├── system/etc/recovery.fstab   # init + fastbootd 用（fs_mgr 格式）
│   ├── system/bin/                 # keymaster/gatekeeper 服务、rebootedl.sh
│   ├── system/lib/                 # HAL 依赖库（含 libQSEEComAPI、libqtikeymaster4）
│   │   └── hw/                     # gatekeeper 的 hw 实现模块
│   └── vendor/etc/vintf/manifest.xml
├── prebuilt/                       # 原机 zImage / dtb / recovery_dtbo
├── docs/                           # 镜像解析证据 + 修复说明
└── .github/workflows/build.yml     # TWRP 12.1 minimal manifest 云编译
```

## 编译

推到 GitHub 后跑 **Build TWRP (OWW251)** 工作流，产物是
`out/target/product/OWW251/recovery.img`（约 16 MB，AVB 会补齐到 64 MiB 分区大小）。

本地编译：

```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
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
回滚原厂 recovery：用 OFP 里的 `recovery.img` 同样 dd 回去。

## 菜单项没出现时的替代入口

* EDL：TWRP 终端里执行 `rebootedl.sh`，或 PC 上 `adb reboot edl`。
* fastbootd：PC 上 `adb reboot fastboot`（写入 boot-fastboot BCB，ABL 会带 `--fastboot` 启动 recovery）。
* 挂载：TWRP 终端里 `ls /dev/block/mapper` 看 dm 设备是否建出来。

## 已知仍需实机确认

1. **/data 解密**：crypto 已经编进去了，keymaster/gatekeeper 也已就位，但本机是
   `metadata 加密 + wrappedkey_v0 + inlinecrypt`，TWRP 对这套组合的支持要在表上跑一次才知道。
   进 TWRP 后把 `/tmp/recovery.log` 拉出来，看 `crypto` 相关行即可定位（见 docs/05）。
2. **触摸**：`TW_INPUT_BLACKLIST := "hbtp_vm"` 沿用原树，若触摸无响应需 `getevent -p` 换设备名。
3. **亮度**：`TW_BRIGHTNESS_PATH` 用的是 `/sys/class/backlight/panel0-backlight/brightness`，
   与 stock init 写的路径一致。
