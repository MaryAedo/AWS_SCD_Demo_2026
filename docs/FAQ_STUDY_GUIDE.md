# Guía Técnica de Estudio y FAQ — DevSecOps en AWS

Documento de referencia para exposiciones, rondas de preguntas y
profundización arquitectónica sobre SCA, NVM y CSPM en AWS.

---

## 📌 Preguntas Frecuentes de la Demostración

### 1. ¿Por qué el widget “Threats” marca 0 y no activamos GuardDuty?

Es importante distinguir entre **postura/configuración (CSPM)** y
**detección de amenazas activas**:

- **CSPM (Cloud Security Posture Management):** evalúa configuraciones en
  reposo, como el acceso público de un bucket S3 o un Security Group que
  permite SSH desde Internet. AWS Config evalúa los recursos y AWS Security
  Hub gobierna y consolida los hallazgos.
- **Threat Detection (Amazon GuardDuty):** detecta anomalías en tiempo real a
  partir de fuentes como VPC Flow Logs, DNS Logs, CloudTrail y logs de
  auditoría de EKS. Busca indicadores de compromiso como fuerza bruta,
  malware o minería de criptomonedas.

Este laboratorio evalúa configuraciones y vulnerabilidades estáticas en un
despliegue controlado. Por eso no requiere activar GuardDuty ni su periodo de
prueba. Los hallazgos de la demostración provienen del pilar CSPM y de la
inspección estática de software.

### 2. ¿Qué diferencia práctica existe entre SCA y NVM?

- **SCA (Software Composition Analysis):** inspecciona dependencias directas y
  transitivas del código fuente mediante archivos como `package.json`,
  `pom.xml` o `requirements.txt`. Actúa en la máquina del desarrollador o en
  CI/CD antes de construir el artefacto.
- **NVM (Network & Vulnerability Management):** evalúa el sistema operativo,
  bibliotecas del sistema como glibc, OpenSSL y curl, y paquetes instalados en
  el runtime del contenedor o una instancia EC2. En este laboratorio actúa
  sobre la imagen publicada en Amazon ECR mediante Amazon Inspector.

### 3. ¿Por qué el pipeline de SCA detiene el despliegue?

El workflow ejecuta:

```bash
npm audit --audit-level=high
```

Este comando funciona como un *Security Quality Gate*. Si detecta
vulnerabilidades `High` o `Critical`, devuelve `exit code 1`; GitHub Actions
marca el job como fallido e impide que el artefacto avance a empaquetado o
despliegue.

### 4. ¿Qué controles de AWS evalúan los recursos de Terraform?

Dentro del estándar **AWS Foundational Security Best Practices (FSBP)**:

- **`[S3.1]`**: *S3 Block Public Access setting should be enabled*. Valida que
  las cuatro configuraciones de bloqueo público estén habilitadas.
- **`[S3.4]`**: *S3 buckets should have server-side encryption enabled*. Exige
  cifrado en reposo mediante SSE-S3 o SSE-KMS.
- **`[EC2.8]`**: *EC2 security groups should not allow ingress from
  0.0.0.0/0 to port 22*. Restringe SSH desde Internet para reducir escaneos y
  ataques de fuerza bruta.

### 5. ¿Cómo opera Amazon Inspector sobre imágenes de Amazon ECR?

Amazon Inspector escanea automáticamente las capas de una imagen cuando se
publica en ECR. Compara los paquetes instalados con bases de datos de
vulnerabilidades conocidas (CVE) de los proveedores del sistema operativo y
puede enviar los hallazgos a Security Hub sin requerir agentes dentro del
contenedor.

### 6. ¿Es posible crear reglas personalizadas (*Custom Controls*) en AWS Security Hub como en plataformas CNAPP (por ejemplo, Wiz)?

**Sí.** En entornos productivos y corporativos existen dos caminos
principales:

1. **Reglas personalizadas nativas en AWS:**
   - Se crean **AWS Config Custom Rules**, cuya lógica de validación se
     programa mediante funciones **AWS Lambda** (Python o Node.js). Para
     controles declarativos también puede utilizarse **CloudFormation Guard**.
   - Cuando se detecta un incumplimiento, AWS Config genera el resultado de
     cumplimiento. Si se necesita convertirlo en un hallazgo de seguridad,
     una función o integración puede formatearlo con el estándar **ASFF
     (AWS Security Finding Format)** e importarlo en AWS Security Hub mediante
     la API `BatchImportFindings`.
   - Este enfoque permite evaluar requisitos propios, como convenciones de
     etiquetado, cifrado obligatorio o restricciones específicas de red, sin
     depender de un proveedor externo.

2. **Integración con plataformas CNAPP de terceros (Wiz, Prisma Cloud u Orca):**
   - Estas plataformas multicloud analizan grafos de recursos, identidades y
     riesgos correlacionados mediante roles IAM delegados y permisos de
     lectura.
   - Sus conectores pueden transmitir los hallazgos hacia **AWS Security
     Hub**, normalmente mediante integraciones nativas y el formato ASFF.
     Security Hub actúa como punto central de agregación, priorización y
     automatización, mientras que la lógica de análisis y correlación
     permanece en la plataforma CNAPP.

La diferencia principal es el alcance: AWS Config y Lambda ofrecen controles
personalizados sobre recursos de AWS con componentes administrados por el
equipo, mientras que un CNAPP añade visibilidad multicloud y correlación de
riesgos a cambio de una integración y un servicio adicional. Para este
laboratorio, las reglas nativas son suficientes y mantienen la arquitectura
centrada en AWS.

---

## 📚 Documentación Oficial de AWS

- [AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
- [Controles AWS Foundational Security Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/fsbp-standard.html)
- [Escaneo de imágenes ECR con Amazon Inspector](https://docs.aws.amazon.com/inspector/latest/user/scanning-ecr.html)
- [Conceptos fundamentales de AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html)
- [Reglas personalizadas de AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_develop-rules.html)
- [Importación de hallazgos mediante BatchImportFindings](https://docs.aws.amazon.com/securityhub/1.0/APIReference/API_BatchImportFindings.html)
- [Detección de amenazas con Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)

## 🎓 Recursos Recomendados

- [AWS Security Fundamentals en Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/144/aws-security-fundamentals)
- [DevSecOps Engineering on AWS Learning Plan](https://explore.skillbuilder.aws/)
- [AWS Security Hub Workshop](https://catalog.workshops.aws/security-hub/en-US)
- [Amazon Inspector Workshop](https://catalog.workshops.aws/amazon-inspector/en-US)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
