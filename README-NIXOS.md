# Nightcap NixOS (Roblox в VR и Desktop)

Форк [CoderDayton/nightcap](https://github.com/CoderDayton/nightcap) (ветка `vr`) с полной адаптацией под **NixOS**, поддержкой **OpenXR (WiVRn / SteamVR)** и исправлением багов VR.

---

## ⚡ Использование через Nix Flake

### Запуск напрямую без установки:
```bash
# Запуск в режиме VR (OpenXR)
nix run github:rimemist/nightcap-nix#vr

# Обычный десктопный режим
nix run github:rimemist/nightcap-nix#desktop

# Окно настроек
nix run github:rimemist/nightcap-nix -- --settings
```

### Подключение в конфигурацию NixOS:

1. Добавьте вход в ваш `flake.nix`:
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nightcap.url = "github:rimemist/nightcap-nix";
};
```

2. Выберите **один из двух вариантов** подключения в систему:

#### Вариант А: Напрямую через `inputs` (Рекомендуется)
Если у вас модульная конфигурация (например, `configuration.nix`), убедитесь, что в аргументах модуля есть `inputs` (`{ config, pkgs, inputs, ... }:`):
```nix
environment.systemPackages = [
  inputs.nightcap.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

#### Вариант Б: Через оверлей (позволяет писать `pkgs.nightcap`)
В вашем `flake.nix` подключите оверлей:
```nix
nixpkgs.overlays = [
  inputs.nightcap.overlays.default
];
```
После чего в любом месте `configuration.nix` можно использовать стандартный вызов:
```nix
environment.systemPackages = with pkgs; [
  nightcap # или pkgs.nightcap
];
```

---

## 🎮 Локальный запуск (из репозитория)

В корне репозитория есть готовые скрипты со всеми настроенными путями NixOS:

```bash
# 1. VR-режим (OpenXR + WiVRn / SteamVR):
./run-vr.sh

# 2. Обычный режим (без VR, десктоп):
./run-desktop.sh

# 3. Проверка подключения шлема и OpenXR рантайма:
./check-vr.sh

# 4. Окно настроек (GUI):
./run-settings.sh
```

---

## 🛠️ Что исправлено и улучшено:

1. **Исправлена ловушка кнопки Menu в VR (зависание ходьбы):**
   - Нажатие кнопки Menu на Quest вызывало Android App Shell (`channels[27]`), который без Meta Horizon OS навсегда блокировал движение персонажа и переводил левый стик в D-Pad.
   - Добавлен флаг `MOCKTAIL_VR_DISABLE_MENU=1`, блокирующий отправку ломающего 27-го канала в Roblox. Теперь кнопка Menu свободно используется под оверлеи (WayVR / Passthrough) без сбоев ходьбы.
2. **Исправлены блёклые цвета в VR (двойная гамма):**
   - Включен приоритет `sRGB swapchain` (`MOCKTAIL_VR_SRGB=1`), устраняющий пересвеченную («вымытую») картинку в шлеме.
3. **Поддержка драйверов Vulkan на NixOS:**
   - Добавлен автоматический поиск драйверов в `/run/opengl-driver/share/vulkan/icd.d` (включая `radeon_icd.x86_64.json`) и fallback загрузки `libvulkan.so.1`.
4. **Поддержка TLS / WebKitGTK ("TLS support is not available"):**
   - Подключен модуль `glib-networking` (`libgiognutls.so`) через `GIO_EXTRA_MODULES`. Страницы настроек аккаунта и Robux открываются без ошибок.
5. **Полноценный Nix Flake и package.nix:**
   - Автоматически скачивает и собирает все необходимые сабмодули (`OpenXR-SDK`, `smaa`, `Vulkan-Headers`).
   - `wrapProgram` автоматически прописывает все нужные переменные окружения, библиотеки и драйверы.
