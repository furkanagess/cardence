# Cardence API — production image (cardenceapi.app)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Cardence.sln ./
COPY Cardence.Api/Cardence.Api.csproj Cardence.Api/
COPY Cardence.Application/Cardence.Application.csproj Cardence.Application/
COPY Cardence.Domain/Cardence.Domain.csproj Cardence.Domain/
COPY Cardence.Infrastructure/Cardence.Infrastructure.csproj Cardence.Infrastructure/

RUN dotnet restore Cardence.Api/Cardence.Api.csproj

COPY Cardence.Api/ Cardence.Api/
COPY Cardence.Application/ Cardence.Application/
COPY Cardence.Domain/ Cardence.Domain/
COPY Cardence.Infrastructure/ Cardence.Infrastructure/

RUN dotnet publish Cardence.Api/Cardence.Api.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Cardence.Api.dll"]
