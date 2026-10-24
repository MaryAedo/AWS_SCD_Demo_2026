# Glosario Técnico de Términos y Servicios — DevSecOps en AWS

Guía de referencia rápida sobre conceptos de ciberseguridad, estándares de cumplimiento, métricas de severidad y servicios de Amazon Web Services (AWS) empleados en el laboratorio práctico **CloudStore** para el *AWS Student Community Day Chile*.

---

## 🛡️ Conceptos y Pilares Fundamentales de DevSecOps

### Shift-Left Security
Enfoque de ingeniería que consiste en trasladar las pruebas y validaciones de seguridad hacia las etapas más tempranas del ciclo de vida del desarrollo de software (diseño, codificación y CI/CD), en lugar de relegarlas a revisiones manuales previas al paso a producción. Esto reduce drásticamente el costo y el tiempo medio de resolución (MTTR) de las vulnerabilidades.

### SCA (Software Composition Analysis)
Análisis de composición de software. Metodología enfocada en inspeccionar el árbol de dependencias directas y transitivas de código abierto (paquetes npm, NuGet, PyPI, Maven, etc.) para identificar vulnerabilidades de seguridad conocidas (CVEs) y riesgos de licencias en el código fuente.

### NVM (Network & Vulnerability Management)
Gestión de vulnerabilidades y exposición de red. En entornos cloud y microservicios, se encarga de analizar el sistema operativo base, las bibliotecas del sistema (como glibc u OpenSSL), los runtimes de ejecución y la configuración de puertos/redes en instancias virtuales (EC2) o artefactos de contenedores (Docker/OCI).

### CSPM (Cloud Security Posture Management)
Gestión de la postura de seguridad en la nube. Proceso automatizado que audita continuamente la configuración de los recursos cloud en reposo (almacenamiento, identidades, redes, bases de datos) contra marcos normativos y mejores prácticas para prevenir configuraciones incorrectas (*misconfigurations*) y derivas de cumplimiento (*compliance drift*).

### Security Gatekeeper / Quality Gate
Criterio o regla de control de calidad implementada en un flujo de integración continua (CI/CD). Si una evaluación automatizada detecta vulnerabilidades que superan un umbral predefinido (ej. severidad `High` o `Critical`), el pipeline aborta la ejecución con un código de error (`exit code 1`), bloqueando la creación de artefactos o despliegues no autorizados.

### CI/CD (Continuous Integration / Continuous Delivery)
Prácticas y automatizaciones que integran cambios de código con frecuencia y
los validan mediante un pipeline reproducible. **CI** ejecuta compilaciones,
pruebas y análisis; **CD** prepara o entrega los artefactos a los entornos de
destino. En este laboratorio, GitHub Actions ejecuta el análisis SCA y la
publicación de la imagen en ECR.

### IaC (Infrastructure as Code)
Administración de infraestructura mediante archivos versionados y declarativos,
en lugar de configuraciones manuales en la consola. Terraform es la
herramienta IaC utilizada para declarar el bucket S3 y el Security Group del
escenario CSPM.

### Artefacto
Resultado versionado y distribuible de un proceso de construcción, como un
paquete npm, una imagen de contenedor o un archivo compilado. La seguridad
debe validarse antes de promover el artefacto a otro entorno.

### Vulnerabilidad
Debilidad técnica que puede ser aprovechada para afectar la confidencialidad,
integridad o disponibilidad de un sistema. Una vulnerabilidad puede estar en
una dependencia, una imagen base, una configuración cloud o una exposición de
red.

### Hallazgo (*Finding*)
Registro estructurado de una observación de seguridad. Incluye normalmente el
recurso afectado, la regla o fuente que lo detectó, la severidad, el estado y
la recomendación de remediación. Security Hub centraliza hallazgos de
servicios propios e integraciones externas.

### Remediación
Acción para corregir la causa de un hallazgo y reducir su riesgo, por ejemplo
actualizar una dependencia, usar una imagen base soportada, restringir un
Security Group o habilitar el cifrado de S3.

---

## ☁️ Servicios de AWS Utilizados y Relacionados

### AWS Security Hub
Servicio centralizado de gestión de postura de seguridad y cumplimiento. Recopila, normaliza y prioriza hallazgos provenientes de múltiples servicios nativos de AWS (AWS Config, Amazon Inspector, Amazon GuardDuty, IAM Access Analyzer) y de soluciones de terceros.

### AWS FSBP (AWS Foundational Security Best Practices)
Estándar de seguridad nativo y seleccionado por AWS en Security Hub. Aplica un conjunto de reglas y controles automatizados que validan continuamente si las cuentas y recursos siguen las recomendaciones oficiales de arquitectura segura de AWS (ej. controles `[S3.1]`, `[S3.4]`, `[EC2.8]`).

### AWS Config
Servicio que registra, evalúa y audita de forma continua los cambios en las configuraciones de los recursos de AWS. Es el motor subyacente que valida si un recurso cumple (*COMPLIANT*) o no (*NON_COMPLIANT*) con una regla determinada.

### Amazon Inspector
Servicio automatizado de gestión de vulnerabilidades que analiza continuamente cargas de trabajo en AWS. En instancias EC2 analiza el sistema operativo mediante el agente SSM; en Amazon ECR analiza las capas de las imágenes de contenedores en busca de CVEs y paquetes de software desactualizados o sin soporte.

### Amazon ECR (Elastic Container Registry)
Registro de contenedores Docker administrado por AWS, totalmente integrado con IAM y Amazon Inspector para almacenar, compartir y escanear imágenes de contenedores de forma segura y privada.

### AWS Systems Manager (SSM) y SSM Agent
* **SSM Agent:** Software ligero de código abierto instalado en instancias EC2 o servidores locales que permite la comunicación bidireccional saliente y cifrada hacia la consola de AWS.
* **Session Manager:** Característica de SSM que permite conectarse por consola a una máquina virtual sin necesidad de abrir puertos de entrada (como el puerto 22 de SSH o 3389 de RDP), sin llaves `.pem` y sin asignar direcciones IP públicas.
* **Inventario e Inspector:** El agente cataloga los paquetes instalados en el sistema operativo, información que Amazon Inspector utiliza para evaluar vulnerabilidades en máquinas virtuales.

### Amazon GuardDuty
Servicio de detección inteligente de amenazas (*Threat Detection*). A diferencia de CSPM (que evalúa configuraciones estáticas), GuardDuty analiza flujos de datos en tiempo real (VPC Flow Logs, DNS Query Logs, CloudTrail Management Events, eventos de EKS) mediante aprendizaje automático e inteligencia de amenazas para identificar ataques activos (fuerza bruta, conexiones a redes Tor, software de criptominería).

### IAM (Identity and Access Management)
Servicio y modelo de AWS para administrar identidades, usuarios, roles,
políticas y permisos. Las credenciales utilizadas por automatizaciones deben
pertenecer a una identidad controlada y nunca exponerse en el código fuente.

### Principio de mínimo privilegio
Práctica de otorgar únicamente los permisos necesarios para una tarea y por
el tiempo requerido. Para GitHub Actions, una alternativa más robusta que las
claves estáticas es usar credenciales federadas mediante OIDC y un rol IAM
con permisos limitados sobre ECR.

### Amazon S3 (Simple Storage Service)
Servicio de almacenamiento de objetos de AWS. En el escenario CSPM, un bucket
con acceso público o sin cifrado representa una configuración insegura que
Security Hub puede identificar mediante controles FSBP.

### Security Group
Firewall virtual con estado asociado a recursos como instancias EC2. Sus
reglas de entrada y salida controlan el tráfico por protocolo, puerto y
origen o destino. Permitir SSH (`22`) desde `0.0.0.0/0` expone el recurso a
Internet y aumenta el riesgo de ataques automatizados.

### OIDC (OpenID Connect)
Protocolo de federación que permite a GitHub Actions obtener credenciales
temporales de AWS mediante un rol IAM, sin almacenar una clave secreta de
larga duración en los secretos del repositorio.

### Región de AWS
Área geográfica aislada que contiene varias zonas de disponibilidad. Los
servicios, recursos, hallazgos y configuraciones pueden depender de la región;
por eso este laboratorio utiliza explícitamente `us-east-1`.

### ECR repository e image tag
Un **repository** de ECR agrupa imágenes relacionadas. Una **tag**, como
`latest`, identifica una versión lógica de una imagen. Para trazabilidad en
producción se recomiendan tags inmutables basadas en un commit o digest, en
lugar de depender únicamente de `latest`.

### Digest de imagen
Identificador criptográfico inmutable, normalmente un SHA-256, que representa
el contenido exacto de una imagen de contenedor. Permite desplegar una versión
verificable aunque una etiqueta sea reutilizada.

---

## 📐 Estándares de Seguridad y Protocolos

### CVE (Common Vulnerabilities and Exposures)
Glosario internacional y estandarizado de identificadores públicos asignados a vulnerabilidades de ciberseguridad conocidas en software y firmware (ej. `CVE-2022-21824`).

### CVSS (Common Vulnerability Scoring System)
Marco estándar abierto para evaluar y comunicar la gravedad de las vulnerabilidades de software mediante una escala numérica de **0.0 a 10.0**:
* **None:** 0.0
* **Low:** 0.1 – 3.9
* **Medium:** 4.0 – 6.9
* **High:** 7.0 – 8.9
* **Critical:** 9.0 – 10.0

### ASFF (AWS Security Finding Format)
Formato JSON estándar y abierto utilizado por AWS Security Hub para normalizar todos los hallazgos de seguridad generados por servicios nativos y soluciones de terceros (facilitando filtros unificados, correlación y automatización de respuestas).

### EoL (End-of-Life)
Designación que indica que un producto o versión de software (ej. .NET 6) ha finalizado su ciclo de soporte por parte del fabricante. No recibe actualizaciones de seguridad, parches de mantenimiento ni asistencia técnica, lo que convierte su uso en un riesgo crítico de seguridad.

### CIS AWS Foundations Benchmark
Conjunto de directrices de configuración prescriptivas y consensuadas por la industria (desarrolladas por el *Center for Internet Security*) para fortalecer la seguridad de las cuentas de AWS a nivel de identidades, almacenamiento, registros y redes.

### SBOM (Software Bill of Materials)
Inventario legible por máquinas de los componentes que forman un artefacto,
incluidas dependencias directas y transitivas. Facilita conocer el alcance de
un CVE y acelerar la respuesta ante vulnerabilidades de la cadena de
suministro.

### CVE EoL y riesgo de soporte
Una alerta de software **EoL** indica que el fabricante dejó de ofrecer
soporte de seguridad para esa versión. Aunque no implique una explotación
activa por sí sola, aumenta el riesgo porque las vulnerabilidades futuras no
recibirán parches oficiales.

### Compliance drift
Desviación progresiva entre la configuración declarada o aprobada y el estado
real de un recurso. AWS Config y las revisiones de IaC ayudan a detectar esta
deriva antes de que se convierta en una exposición persistente.

---

## 🏢 Arquitectura Empresarial y Extensiones

### CNAPP (Cloud Native Application Protection Platform)
Plataforma que unifica múltiples capacidades de seguridad en la nube (CSPM, CWPP, CIEM, escaneo de artefactos) en una sola solución con análisis basado en grafos de riesgo (ej. Wiz, Palo Alto Prisma Cloud, Orca Security).

### AWS Config Custom Rules
Reglas de auditoría personalizadas implementadas por los equipos de ingeniería cuando las reglas predeterminadas no cubren una política corporativa interna. Se construyen mediante funciones **AWS Lambda** (Python, Node.js) o mediante lenguaje declarativo con **CloudFormation Guard**, y envían sus hallazgos a Security Hub usando la API `BatchImportFindings`.

### CWPP (Cloud Workload Protection Platform)
Capacidad de protección de cargas de trabajo cloud, como máquinas virtuales,
contenedores y funciones. Puede incluir inventario, análisis de vulnerabilidades
y controles de ejecución. Forma parte de varias plataformas CNAPP, pero no
equivale por sí sola a una estrategia completa de seguridad cloud.

### CIEM (Cloud Infrastructure Entitlement Management)
Disciplina enfocada en analizar permisos y derechos de acceso en entornos
cloud para detectar privilegios excesivos, identidades inactivas y rutas de
acceso riesgosas. Complementa a CSPM, que se concentra principalmente en la
configuración de los recursos.

### Container image layers
Capas inmutables que componen una imagen OCI o Docker. Cada instrucción del
Dockerfile puede generar una capa; los escáneres revisan esas capas para
identificar paquetes vulnerables, archivos innecesarios y secretos expuestos.