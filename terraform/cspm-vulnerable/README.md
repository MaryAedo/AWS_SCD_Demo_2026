# Módulo CSPM: Detección de Postura en AWS Security Hub

Este módulo simula la infraestructura de almacenamiento y red de CloudStore,
configurada con malas prácticas comunes para evaluar controles de **Cloud
Security Posture Management**.

## Presupuesto mensual

El archivo `budget.tf` crea un presupuesto mensual de `5 USD` con dos
notificaciones:

- consumo real superior al `80%`;
- previsión de superar el `100%`.

El correo de notificación se recibe mediante la variable sensible
`budget_alert_email`; no se guarda una dirección personal en el repositorio.
Desde PowerShell, ejecuta:

```powershell
cd C:\Demo_AWS_SCD2026\terraform\cspm-vulnerable
terraform plan -var="budget_alert_email=TU_CORREO"
terraform apply -var="budget_alert_email=TU_CORREO"
```

Si prefieres no exponer el correo en el historial de comandos, usa un archivo
local `terraform.tfvars` (no lo subas al repositorio):

```hcl
budget_alert_email = "tu-correo@example.com"
```

Después ejecuta:

```powershell
terraform plan
terraform apply -auto-approve
```

## Archivos

- `main.tf`: declaración deliberadamente insegura del bucket S3 y el Security
  Group.
- `budget.tf`: presupuesto mensual y alertas de costo.
- `variables.tf`: variable sensible para el correo de alertas.
- `../cspm-remediated/main.tf`: ubicación sugerida para el código corregido
  con controles compensatorios y cifrado obligatorio.

## Vulnerabilidades Esperadas

### 1. `[S3.1]` S3 Block Public Access setting should be enabled

- **Servicio:** Amazon S3 / AWS Security Hub (FSBP y CIS Benchmark).
- **Severidad:** Critical / High.
- **Significado:** el bucket carece de bloqueos a nivel de cuenta o bucket para
  ACL y políticas públicas.

Remediación:

```hcl
resource "aws_s3_bucket_public_access_block" "secure_block" {
  bucket                  = aws_s3_bucket.insecure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 2. `[S3.4]` S3 buckets should have server-side encryption enabled

- **Servicio:** Amazon S3 / AWS Security Hub.
- **Severidad:** Medium / High.
- **Significado:** los objetos no tienen cifrado en reposo configurado por
  defecto, lo que puede incumplir PCI-DSS e ISO 27001.

Remediación:

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.insecure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 3. `[EC2.8]` EC2 security groups should not allow ingress from `0.0.0.0/0` to port 22

- **Servicio:** Amazon EC2 / AWS Security Hub.
- **Severidad:** High.
- **Significado:** el puerto SSH queda expuesto a ataques de fuerza bruta y
  escaneos automatizados.

Remediación: restringir el origen a una VPN o bastión interno, o reemplazar
SSH por AWS Systems Manager Session Manager.
