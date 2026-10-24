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

---

## 📚 Documentación Oficial de AWS

- [AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
- [Controles AWS Foundational Security Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/fsbp-standard.html)
- [Escaneo de imágenes ECR con Amazon Inspector](https://docs.aws.amazon.com/inspector/latest/user/scanning-ecr.html)
- [Conceptos fundamentales de AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html)
- [Detección de amenazas con Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)

## 🎓 Recursos Recomendados

- [AWS Security Fundamentals en Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/144/aws-security-fundamentals)
- [DevSecOps Engineering on AWS Learning Plan](https://explore.skillbuilder.aws/)
- [AWS Security Hub Workshop](https://catalog.workshops.aws/security-hub/en-US)
- [Amazon Inspector Workshop](https://catalog.workshops.aws/amazon-inspector/en-US)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
