php8
frankenphp
octane

## Octane Worker 配置

默认情况下，容器会以 `auto` 模式启动 Octane。
这个模式会同时参考 CPU 核数和可用内存来计算 worker 数量，比单纯按 CPU 自动分配更适合同时兼容低配和高配服务器。

### 手动指定 worker 数量

如果你想手动控制 Octane 的 worker 数量，可以在启动容器时传入 `OCTANE_WORKERS`。

示例：

```bash
docker run -e OCTANE_WORKERS=4 -p 8000:8000 your-image
```

这会实际执行：

```bash
php artisan octane:start --server=frankenphp --host=0.0.0.0 --port=8000 --workers=4
```

建议参考：

- 小机器：`OCTANE_WORKERS=1`
- 中等机器：`OCTANE_WORKERS=2`
- 大机器：`OCTANE_WORKERS=4`

最终数值建议根据你的业务实际压测结果调整。

### 自动模式下限制最大 worker 数

如果你希望继续使用自动计算，但又不想让高配机器启动太多 worker，可以设置 `OCTANE_MAX_WORKERS`。

示例：

```bash
docker run -e OCTANE_MAX_WORKERS=4 -p 8000:8000 your-image
```

这表示：

- 仍然会自动计算 worker 数
- 但最终不会超过 `4`

### 可用环境变量

- `OCTANE_WORKERS`：手动指定 worker 数量，默认是 `auto`
- `OCTANE_MAX_WORKERS`：仅在 `OCTANE_WORKERS=auto` 时生效，用来限制最大 worker 数
- `OCTANE_MEMORY_PER_WORKER_MB`：自动模式下每个 worker 预估占用的内存，默认 `256`
- `OCTANE_MEMORY_RESERVE_MB`：自动模式下预留给系统和其他进程的内存，默认 `512`
- `OCTANE_MAX_REQUESTS`：单个 worker 处理多少次请求后自动重启

## 基于这个镜像构建业务镜像

如果你要在自己的 Laravel 项目里基于这个镜像继续构建，可以这样写：

```dockerfile
FROM draguo/laravel:octane-frankenphp

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader
```

如果你想在业务镜像里直接手动指定 worker 数量，可以继续加上 `ENV`：

```dockerfile
FROM draguo/laravel:octane-frankenphp

WORKDIR /var/www/html

ENV OCTANE_WORKERS=4

COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader
```

如果你想保留自动模式，但限制上限，也可以这样写：

```dockerfile
FROM draguo/laravel:octane-frankenphp

WORKDIR /var/www/html

ENV OCTANE_MAX_WORKERS=4

COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader
```
