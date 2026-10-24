# CloudStore DevSecOps Lab: CSPM, NVM & SCA Remediation

> **AWS Student Community Day**  
> Repositorio oficial del taller y demostración técnica: *De la Detección a la Remediación Continua*.

## Contexto y Propósito

En este laboratorio simulamos la arquitectura de **CloudStore**, una plataforma
de e-commerce ficticia cuyo equipo de desarrollo priorizó la velocidad de
entrega (*time-to-market*) por sobre los controles de seguridad.

El repositorio contiene código vulnerable intencional y recetas de remediación
estructuradas en tres disciplinas esenciales de DevSecOps:

1. **CSPM (Cloud Security Posture Management):** auditoría de configuraciones e
   infraestructura en AWS mediante **AWS Security Hub**.
2. **NVM (Network & Vulnerability Management):** detección de fallos en el
   sistema operativo y runtimes obsoletos mediante **Amazon Inspector** y
   escaneo de contenedores.
3. **SCA (Software Composition Analysis):** detección de dependencias con CVEs
   conocidos dentro de pipelines de **GitHub Actions**.

## Arquitectura del Sistema Simulado (CloudStore)

```text
[ Usuario / Internet ]
         │
         ▼
┌────────────────────────────────────────────────────────┐
│  1. Fachada & Almacenamiento (CSPM)                    │
│  • Bucket S3: catálogo multimedia público y sin cifrar │
│  • Security Group: puerto SSH (22) a 0.0.0.0/0         │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────┐
│  2. Backend & Cómputo (NVM)                            │
│  • API en contenedor: runtime .NET 6 (EoL)             │
│  • SO base desactualizado con OpenSSL/curl vulnerable  │
│  • SSH con autenticación root por contraseña           │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────┐
│  3. Frontend Web & CI/CD (SCA)                         │
│  • Librerías Axios/Lodash antiguas                     │
│  • Bloqueo automatizado del build en GitHub Actions    │
└────────────────────────────────────────────────────────┘
```

## Matriz General de Vulnerabilidades (9 Hallazgos)

| Dominio | Servicio / herramienta | Identificador | Impacto / riesgo técnico |
| :--- | :--- | :--- | :--- |
| CSPM | AWS Security Hub | `[S3.1]` | Bucket S3 con acceso público habilitado |
| CSPM | AWS Security Hub | `[S3.4]` | Bucket S3 sin cifrado en reposo forzado |
| CSPM | AWS Security Hub | `[EC2.8]` | SSH del Security Group a `0.0.0.0/0` |
| NVM | Amazon Inspector / ECR | EoL Software | Runtime Microsoft .NET 6 fuera de soporte |
| NVM | Amazon Inspector / Host | OS CVEs | Paquetes base desactualizados en Debian Bullseye |
| NVM | Amazon Inspector / Host | CWE-287 | `PermitRootLogin yes` en SSH |
| SCA | GitHub Actions / npm | CVE-2021-3749 | ReDoS en `axios@0.21.1` |
| SCA | GitHub Actions / npm | CVE-2020-8203 | Prototype Pollution en `lodash@4.17.15` |
| SCA | GitHub Actions / npm | CVE-2021-44906 | Prototype Pollution en `minimist@1.2.0` |

## Prerrequisitos y Preparación del Entorno

Antes de clonar el repositorio y desplegar los escenarios, asegúrate de contar
con las siguientes herramientas locales y servicios de AWS configurados.

### 1. Herramientas Locales

- **Git:** control de versiones ([Descargar Git](https://git-scm.com/)).
- **AWS CLI v2:** interfaz de línea de comandos configurada
  ([guía oficial](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)).
- **Docker Desktop:** para compilar y empaquetar el workload de NVM
  ([Descargar Docker](https://docs.docker.com/get-docker/)).
- **Node.js (v18+):** para las pruebas locales de dependencias SCA
  ([Descargar Node](https://nodejs.org/)).
- Una cuenta AWS de laboratorio aislada.

### 2. Instalación y Configuración de Terraform en Windows

Para ejecutar los despliegues de Infraestructura como Código
(`terraform/cspm-vulnerable`), debes tener Terraform instalado y enlazado al
PATH del sistema.

#### Opción A: Gestor de Paquetes (Recomendada)

Abre **PowerShell** o **Windows Terminal** como Administrador:

```powershell
# Vía Winget (Windows 10/11)
winget install HashiCorp.Terraform

# Vía Chocolatey
choco install terraform
```

#### Opción B: Instalación Manual y Variable PATH

1. Descarga el binario para Windows (AMD64) desde el
   [portal de HashiCorp](https://developer.hashicorp.com/terraform/install).
2. Crea la carpeta fija `C:\Terraform` y extrae dentro el archivo
   `terraform.exe`.
3. Presiona la tecla **Windows**, busca **Editar las variables de entorno del
   sistema** y entra a **Variables de entorno...**.
4. En **Variables del sistema**, selecciona **Path** > **Editar...** >
   **Nuevo** y agrega `C:\Terraform`. Guarda con **Aceptar**.
5. Abre una nueva terminal y valida:

   ```powershell
   terraform -version
   ```

### Activación de AWS Security Hub (Paso a Paso en Nueva Consola)

AWS Security Hub implementa una separación clara entre capacidades esenciales
y complementos (*Add-ons*). Para fines de laboratorio y costo cero, sigue esta
selección estricta.

#### 1. Selección de Capacidades (*Security capabilities*)

Marca **Enable essential (Cost optimized)**.

- ✅ Incluye *Security Hub CSPM checks*, correlación de recursos e inventario,
  y escaneo de vulnerabilidades con Amazon Inspector (EC2/ECR).
- 🎁 **Cobertura:** cubierta al 100% por el **30-day free trial**, sujeto a
  la elegibilidad y condiciones vigentes de AWS.
- ❌ **No selecciones Enable all:** los add-ons de GuardDuty (malware scanning
  y runtime monitoring para EKS/ECS), así como los escaneos de código
  avanzados, pueden cobrarse por separado una vez procesados eventos o
  gigabytes de telemetría.

#### 2. Selección de Regiones (*Regions*)

Selecciona **Enable specific Regions** y marca únicamente **N. Virginia
(`us-east-1`)**.

Evita habilitar todas las regiones (**Enable in all Regions**) para no activar
grabadores de AWS Config en regiones innecesarias.

#### 3. Etiquetado Estratégico para Billing (*Resource Tags*)

Antes de presionar activar, despliega **Resource tags** y agrega las siguientes
etiquetas para monitoreo en AWS Cost Explorer y Budgets:

```text
Key: Environment   | Value: Lab-CommunityDay
Key: Project       | Value: CloudStore-DevSecOps
Key: ManagedBy     | Value: Console-Manual
```

#### 4. Estándares de Seguridad (*Security Standards*)

Después de seleccionar las capacidades, habilita los estándares necesarios para
esta demostración:

- ✅ **AWS Foundational Security Best Practices (FSBP) v1.0.0**, imprescindible
  para detectar las alertas de S3 público, cifrado y Security Groups.
- ✅ **CIS AWS Foundations Benchmark v1.4.0** o **v1.2.0**, para auditoría y
  cumplimiento.
- ⚪ Estándares adicionales como PCI-DSS o NIST pueden dejarse desmarcados para
  evitar ruido inicial.

#### 5. Confirmación

- Haz clic en **Enable Security Hub**. La consola aprovisionará
  automáticamente el rol de servicio `AWSServiceRoleForSecurityHub`.

### Verificación posterior a la activación

Una vez dentro de la consola de Security Hub:

1. Dirígete a **Security standards** en el menú de navegación izquierdo.
2. Comprueba que **AWS Foundational Security Best Practices (FSBP) v1.0.0**
   figure en estado **Enabled**.
3. Verifica en **Settings > Usage** que tu período de 30 días gratuitos
   muestre la fecha de finalización (**Trial expiration date**).

#### 6. Verificar AWS Config

Security Hub requiere que **AWS Config** esté grabando el estado de los
recursos. Si aparece el banner *AWS Config is not recording in this Region*,
haz clic en el enlace, selecciona **Set up AWS Config** y habilita la grabación
al menos para `S3 Bucket` y `EC2 SecurityGroup`.

#### 7. Monitorear el Free Trial

Continúa revisando **Settings > Usage** para controlar el consumo y el costo
estimado de la cuenta durante el laboratorio.

## Guía de Replicación Paso a Paso

### Paso 1: Configuración de Credenciales Seguras en AWS (IAM vs Root)

> ⚠️ **Advertencia de seguridad:** si acabas de crear tu cuenta de AWS, habrás
> iniciado sesión con el usuario **Root**. Como buena práctica fundamental de
> DevSecOps, **nunca generes Access Keys para el usuario root**. Debes crear un
> usuario administrativo delegado en IAM.

#### 1. Creación del Usuario IAM Delegado

1. En la consola de AWS, ingresa al servicio **IAM** > **Users** >
   **Create user**.
2. Asigna un nombre, por ejemplo `admin-devsecops`. No es necesario habilitar
   acceso a la consola web para este usuario si solo se utilizará mediante CLI.
3. En **Set permissions**, selecciona **Attach policies directly** y asocia la
   política gestionada `AdministratorAccess` para este laboratorio.
4. Revisa los detalles y haz clic en **Create user**.

> Para entornos reales, aplica el principio de mínimo privilegio y evita usar
> permisos administrativos permanentes. `AdministratorAccess` se documenta aquí
> únicamente para simplificar este laboratorio.

#### 2. Generación de Access Keys

1. Haz clic sobre el usuario creado (`admin-devsecops`) y dirígete a la pestaña
   **Security credentials**.
2. En **Access keys**, selecciona **Create access key**.
3. Selecciona **Command Line Interface (CLI)**, acepta la casilla de
   confirmación y haz clic en **Next** > **Create access key**.
4. Copia y resguarda de inmediato:
   - **Access Key ID** (`AKIA...`).
   - **Secret Access Key**.

No compartas estas claves ni las guardes en el repositorio. Para cuentas
educativas o entornos compatibles, prefiere credenciales temporales mediante
IAM Identity Center, AWS Academy o un perfil federado.

#### 3. Vinculación en Terminal Local / VS Code

Abre tu terminal (PowerShell, Bash o la terminal integrada de VS Code) y
ejecuta:

```bash
aws configure
```

Ingresa los parámetros requeridos:

```text
AWS Access Key ID [None]: TU_ACCESS_KEY_ID
AWS Secret Access Key [None]: TU_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

Valida que tus credenciales respondan correctamente contra la API de AWS:

```bash
aws sts get-caller-identity
```

La salida debe mostrar un JSON con tu número de cuenta y el ARN del usuario
`admin-devsecops`.

### 2. Desplegar los escenarios

#### CSPM

```bash
cd terraform/cspm-vulnerable
terraform init
terraform apply -auto-approve
```

Security Hub puede tardar entre 5 y 20 minutos en evaluar las reglas.

#### NVM

```bash
cd ../../nvm-workload
aws ecr create-repository --repository-name cloudstore-backend --region us-east-1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com"
docker build -t cloudstore-backend .
docker tag cloudstore-backend:latest "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/cloudstore-backend:latest"
docker push "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/cloudstore-backend:latest"
```

Inspector analizará la imagen automáticamente en los minutos siguientes.

#### SCA

```bash
cd ../app-sca
npm install
npm audit --audit-level=high
```

El comando debe finalizar con código distinto de cero porque las dependencias
son vulnerables intencionalmente. El pipeline equivalente está en
`.github/workflows/sca-pipeline.yml`.

## Limpieza de Recursos (FinOps: Cero Costo)

Al terminar las pruebas, destruye la infraestructura:

```bash
cd terraform/cspm-vulnerable
terraform destroy -auto-approve
```

Elimina también el repositorio ECR y sus imágenes:

```bash
aws ecr delete-repository \
  --repository-name cloudstore-backend \
  --force \
  --region us-east-1
```

> Estos recursos y dependencias son intencionalmente vulnerables. Úsalos
> únicamente en una cuenta y un entorno de laboratorio aislados, y elimínalos
> al finalizar.

## Preguntas Frecuentes

### ¿Cuánto tarda Security Hub en reflejar una corrección?

Al aplicar un `terraform apply` con el código remediado, el control pasa de
`FAILED` a `PASSED`. El finding original puede cambiar de `ACTIVE` a
`RESOLVED` entre 15 minutos y 2 horas, según el ciclo de evaluación de AWS
Config.

### ¿Por qué .NET 6 es detectado como vulnerabilidad si el código funciona?

.NET 6 alcanzó su fecha de fin de vida en noviembre de 2024. Amazon Inspector y
otros escáneres marcan runtimes EoL porque ya no reciben parches de seguridad.

### ¿Este laboratorio tiene costo en AWS?

Security Hub e Inspector pueden ofrecer períodos de prueba, pero los precios y
la elegibilidad pueden cambiar. Revisa la página de precios de AWS, configura
alertas de facturación y destruye los recursos al terminar.

## Material Adicional

La presentación de la charla puede agregarse opcionalmente en
`docs/slides-presentacion.pdf`.
