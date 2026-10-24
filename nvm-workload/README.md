# Módulo NVM: Vulnerabilidades en Sistemas y Cargas de Cómputo

Este directorio contiene la definición del backend de órdenes de CloudStore,
encapsulado en un contenedor que expone vulnerabilidades a nivel de paquetes
del sistema operativo, políticas de acceso y ciclo de vida del software.

## Archivos

- `Dockerfile`: imagen base obsoleta con runtimes y configuraciones
  vulnerables.

## Vulnerabilidades Esperadas (Amazon Inspector / ECR Scan)

### 1. Runtime .NET 6 (End-of-Life / EoL)

- **Servicio:** Amazon Inspector / Software Inventory.
- **Severidad:** High.
- **Significado:** Microsoft finalizó el soporte oficial para .NET 6 en
  noviembre de 2024.

Remediación: actualizar a un runtime soportado:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim
```

### 2. Paquetes del sistema operativo con CVEs activos

- **Servicio:** Amazon Inspector / Base OS Vulnerability Assessment.
- **Severidad:** Variable (Medium a High).
- **Significado:** la imagen utiliza versiones antiguas de utilitarios como
  `curl` y `openssl` en Debian 11 (Bullseye).

Remediación: migrar a una imagen actualizada y reducir la superficie:

```dockerfile
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*
```

### 3. Configuración débil de acceso SSH (`PermitRootLogin yes`)

- **Servicio:** Amazon Inspector / CIS OS Benchmark.
- **Severidad:** Medium.
- **Significado:** permitir acceso root por contraseña facilita ataques de
  fuerza bruta contra la cuenta con máxima autoridad.

Remediación preferida: deshabilitar SSH en contenedores. Si fuera
imprescindible, exigir llaves y bloquear root:

```text
PermitRootLogin no
PasswordAuthentication no
```
