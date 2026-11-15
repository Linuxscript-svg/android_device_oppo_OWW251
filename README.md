# OPPO Watch X2 (OWW251) TWRP 设备树

由 `recovery.img` 自动生成（twrpdtgen 3.0 + AIK 解包），并按镜像中真实数据修正。

## 设备信息（均来自镜像内 build.prop / recovery.fstab）

| 项目 | 值 |
| --- | --- |
| 品牌 / 厂商 | OPPO |
| 设备代号 | OWW251 |
| 市场名 | OPPO Watch（ro.oppo.market.name）；对应 OPPO Watch X2 机型 |
| 硬件版本 | XK911 |
| 平台 | Qualcomm monaco / monaco_go（安卓穿戴参考平台，TARGET_BOARD_PLATFORM=monaco） |
| 系统 | Android 11（SDK 30），ColorOS Watch V7.0 |
| 固件版本 | OWW251_11_A.87（2025-03-18） |
| 架构 | 纯 32 位 arm，armeabi-v7a / armeabi（无 64 位 ABI） |
| 屏幕 | 466×466 圆形 AMOLED，density 320，`ro.oplus.wear.screen.round=true` |
| 分区方案 | A-only（非 A/B）+ 动态分区（super 内含 system/system_ext/vendor/product/odm） |
| userdata | f2fs + metadata 加密 / wrappedkey（metadata 分区独立挂载） |
| AVB | 已开启（镜像尾部为 AVBv2 签名） |
| 内核镜像 | 32 位 ARM zImage，header v2，page 4096 |

## 目录结构

仓库根目录即 `device/oppo/OWW251/`：

```
.
├── Android.bp
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk          # 板级配置（已按镜像真实值修正）
├── device.mk
├── omni_OWW251.mk          # product 配置
├── extract-files.sh        # 从真机导 vendor blobs（需要真机 /system 可读）
├── setup-makefiles.sh
├── vendorsetup.sh
├── recovery.fstab          # TWRP fstab（挂载点与 fstype 取自原镜像）
├── prebuilt/
│   ├── zImage              # 从 recovery.img 提取的内核
│   ├── dtb.img             # 从 recovery.img 提取的 dtb（250 KB）
│   └── dtbo.img            # 从 recovery.img 提取的 recovery_dtbo（586 KB）
└── recovery/
    └── root/
        └── init.recovery.qcom.rc   # 原镜像 recovery 的 qcom init 规则（含背光/UFS 处理）

docs/                               # 原始解析证据（镜像头、关键属性、原厂 fstab）
```

## 编译方式

```bash
# 以 TWRP minimal manifest（Android 11）为例
mkdir -p device/oppo
git clone https://github.com/Linuxscript-svg/android_device_oppo_OWW251.git device/oppo/OWW251
. build/envsetup.sh
lunch omni_OWW251-eng
mka recoveryimage
```

产物：`out/target/product/OWW251/recovery.img`

刷入（需先解锁 bootloader）：

```bash
fastboot flash recovery recovery.img
# 或临时启动：fastboot boot recovery.img
```

## 生成器已修正的项目

1. `TARGET_USES_64_BIT_BINDER := true` 已删除——本机是纯 32 位用户空间，开启会导致 32 位 recovery 链接/运行 64 位 binder 失败。
2. 补齐 `BOARD_KERNEL_OFFSET=0x00008000`、`BOARD_DTB_OFFSET=0x01f00000`、`--os_version 11.0.0 --os_patch_level 2024-03`，否则打包出的 boot 头与真机不匹配、无法启动。
3. `BOARD_KERNEL_IMAGE_NAME` 由 `Image` 改为 `zImage`（8 MB 以上 32 位 ARM 内核，不是 arm64 Image）。
4. `BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE` 由 ext4 改为 f2fs（fstab 中 userdata 为 f2fs）。
5. 安全补丁改为镜像实际值 2024-03-05（生成器给的 2021-08-01 是错的），并保留防回滚 PLATFORM_SECURITY_PATCH hack。
6. 设备名由 Qualcomm 参考板 `qualcomm/monaco_go` 改为 `oppo/OWW251`，product 名 `omni_OWW251`，fingerprint 用真机 `OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87...`。
7. 增加 `BOARD_USES_METADATA_PARTITION := true`（fstab 存在独立 metadata 分区）与 `TW_ROUND_SCREEN := true`（圆形表盘）。
8. 解密相关 `TW_INCLUDE_CRYPTO` 默认注释——缺 vendor keymaster/gatekeeper blob，开了会编译/运行失败。

## 必须用真机确认的项（生成器无法从 recovery.img 得到）

1. **super 分区实际大小**：`BOARD_SUPER_PARTITION_SIZE` / `BOARD_QUALCOMM_DYNAMIC_PARTITIONS_SIZE` 目前是 8.5 GB 占位值，对这块表几乎肯定偏大。真机执行
   `adb shell ls -l /dev/block/by-name/super` 或 `adb shell cat /proc/partitions` 后替换，否则打包镜像会超出分区。
2. **boot / recovery 分区实际大小**：现在按镜像文件大小填 64 MB（`67108864`），如真机分区不同需同步改。
3. **屏幕分辨率/偏移**：density 320 与 466×466 已由属性与官方规格推定；若 TWRP 界面偏移，需调 `TW_Y_OFFSET` / `TW_X_OFFSET`。
4. **触摸输入**：`TW_INPUT_BLACKLIST := "hbtp_vm"` 为生成器猜测的输入设备名，若触摸无响应需真机 `getevent -p` 后修正。
5. **解密**：/data 为 metadata 加密，要挂载需补 vendor HAL blobs 并打开加密开关。

## 备注

- 内核、dtb、dtbo 均直接取自本机 `recovery.img`，因此与出厂固件版本（11_A.87）严格对应；换固件版本后应重新提取。
- 该机为 `user` 版本（`ro.debuggable=0`、`ro.adb.secure=1`），TWRP 的 adb 需自行处理授权。
