# Módulo SCA: Análisis de Composición de Software y Dependencias

Este directorio simula el frontend web de compras de CloudStore, integrando
dependencias de terceros desactualizadas con vulnerabilidades conocidas y
verificables en el National Vulnerability Database (NVD).

## Archivos

- `package.json`: manifiesto con versiones vulnerables intencionales.
- `../.github/workflows/sca-pipeline.yml`: pipeline que actúa como puerta de
  seguridad (*Security Gate*).

## Vulnerabilidades Esperadas

### 1. `axios@0.21.1` — CVE-2021-3749

- **Ecosistema:** npm / Node.js.
- **Severidad:** High (CVSS 7.5).
- **Significado:** ReDoS en el procesamiento de encabezados, que puede
  consumir CPU del hilo principal.

Remediación: actualizar a `axios@0.21.2` o superior.

### 2. `lodash@4.17.15` — CVE-2020-8203

- **Ecosistema:** npm / Node.js.
- **Severidad:** High (CVSS 7.4).
- **Significado:** Prototype Pollution en `set`, `setWith` y `zipObjectDeep`.

Remediación: actualizar a `lodash@4.17.21` o sustituir los métodos afectados.

### 3. `minimist@1.2.0` — CVE-2021-44906

- **Ecosistema:** npm / Node.js.
- **Severidad:** Critical / High (CVSS 7.8).
- **Significado:** Prototype Pollution durante el parseo de argumentos con
  nombres especiales como `__proto__`.

Remediación: actualizar a `minimist@1.2.6` o superior.

## Cómo Ejecutar la Remediación

Para corregir automáticamente las dependencias y volver a poner el pipeline en
verde:

```bash
npm audit fix
git add package.json package-lock.json
git commit -m "fix(security): remedia dependencias vulnerables (SCA)"
git push origin main
```
