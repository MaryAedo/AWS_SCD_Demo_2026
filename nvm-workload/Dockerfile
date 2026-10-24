# NVM Issue 1: Imagen base antigua con .NET 6 oficial (EoL desde fines de 2024)
FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim

# NVM Issue 2: Paquetes del SO con CVEs sin parchar (OpenSSL antiguo)
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server curl && \
    rm -rf /var/lib/apt/lists/*

# NVM Issue 3: Debilidad de configuración en el servicio SSH del host
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

WORKDIR /app
COPY app/ .

CMD ["dotnet", "--info"]
