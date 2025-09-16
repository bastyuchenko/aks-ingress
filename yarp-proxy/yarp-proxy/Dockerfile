FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["YarpProxy.csproj", "YarpProxy/"]
RUN dotnet restore "YarpProxy/YarpProxy.csproj"

COPY . YarpProxy/
WORKDIR "/src/YarpProxy"
RUN dotnet build "YarpProxy.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "YarpProxy.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user for security
RUN adduser --disabled-password --gecos '' --uid 1001 appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "YarpProxy.dll"]