# NVM Issue 1: Runtime obsoleto sin soporte de seguridad (End-of-Life / EoL)
FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim

WORKDIR /app

# NVM Issue 3: Hardening deficiente - Simulación de configuración insegura
RUN mkdir -p /etc/ssh && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Simulación de binario de la aplicación
RUN echo 'Console.WriteLine("CloudStore API - Vulnerable .NET 6 Runtime");' > /app/app.dll

USER root
EXPOSE 80 22

ENTRYPOINT ["dotnet", "app.dll"]
