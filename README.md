# CloudStore — DevSecOps Security Lab (AWS Student Community Day 2026)

Repositorio oficial del laboratorio práctico de DevSecOps presentado en el AWS
Student Community Day Chile 2026. Este proyecto demuestra controles de
seguridad en tres capas críticas del ciclo de vida del software: dependencias
de código (**SCA**), artefactos y contenedores (**NVM**), e infraestructura como
código en AWS (**CSPM**).

---

## 🎯 Arquitectura del Laboratorio y Alcance

El laboratorio aborda un ciclo de vida completo bajo el principio de *Shift-Left
Security*, mitigando vulnerabilidades antes y durante el despliegue en AWS:

```text
[Desarrollador / Git Commit]
           │
           ▼
[GitHub Actions CI/CD] ──> (Pilar 1: SCA) ──> npm audit bloquea dependencias críticas
           │
           ▼
[Amazon ECR / Inspector] ──> (Pilar 2: NVM) ──> Análisis de imagen .NET 6 EoL
           │
           ▼
[AWS Security Hub / Config] ──> (Pilar 3: CSPM) ──> Detección de S3 público y SG expuesto
```

## 📂 Estructura del Repositorio

- `app-sca/`: aplicación Node.js con dependencias vulnerables intencionales y
  pipeline de bloqueo en GitHub Actions.
- `nvm-workload/`: `Dockerfile` basado en un runtime .NET obsoleto y pipeline
  de empaquetado hacia Amazon ECR.
- `terraform/cspm-vulnerable/`: plantillas Terraform que declaran un bucket S3
  público y un Security Group con SSH expuesto a `0.0.0.0/0`.
- `docs/`: material complementario, capturas de respaldo y guías de estudio.
  Consulta la [guía técnica y FAQ](docs/FAQ_STUDY_GUIDE.md), el
  [material de preparación de Security Hub](docs/Preparando_SecurityHub.pdf) y
  las [evidencias visuales](docs/evidence/).

## 🚀 Despliegue Rápido del Laboratorio

### Requisitos Previos

- Cuenta de AWS activa con permisos de administración delegada.
- AWS CLI configurado mediante `aws configure`.
- Terraform v1.5 o superior.
- Secretos `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY` configurados en
  GitHub Actions.

### Paso 1: Pilar CSPM

```bash
cd terraform/cspm-vulnerable
terraform init
terraform apply -auto-approve
```

### Paso 2: Pilar SCA

Al realizar un commit o push a la rama principal, el workflow
`.github/workflows/sca-pipeline.yml` ejecuta `npm audit` y falla ante
vulnerabilidades de severidad High o Critical.

### Paso 3: Pilar NVM

Desde la pestaña **Actions** de GitHub, ejecuta manualmente el workflow
**Build and Push NVM Workload to ECR** para compilar la imagen vulnerable y
enviarla al repositorio `cloudstore-backend` en `us-east-1`.

## 🛡️ Verificación en la Consola de AWS

1. Accede a **AWS Security Hub** en `us-east-1`.
2. En **Findings > Posture management**, filtra por severidad `Critical` y
   `High` para auditar los hallazgos `[S3.1]`, `[S3.4]` y `[EC2.8]`.
3. En **Findings > Vulnerabilities**, inspecciona los CVE detectados por
   Amazon Inspector en `cloudstore-backend`.

## 🧹 Destrucción de Recursos

Para evitar consumos fuera de la capa gratuita, elimina los recursos al
finalizar el laboratorio:

```bash
# Eliminar infraestructura CSPM
cd terraform/cspm-vulnerable
terraform destroy -auto-approve

# Eliminar repositorio ECR e imágenes
aws ecr delete-repository \
  --repository-name cloudstore-backend \
  --force \
  --region us-east-1
```
