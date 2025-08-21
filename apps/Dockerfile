FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/HelloWorldApi.csproj", "src/"]
COPY ["tests/HelloWorldApi.Tests.csproj", "tests/"]
RUN dotnet restore "src/HelloWorldApi.csproj"
RUN dotnet restore "tests/HelloWorldApi.Tests.csproj"

COPY . .
WORKDIR "/src/src"
RUN dotnet build "HelloWorldApi.csproj" -c Release -o /app/build

FROM build AS test
WORKDIR "/src/tests"
RUN dotnet test "HelloWorldApi.Tests.csproj" --no-restore --verbosity normal

FROM build AS publish
WORKDIR "/src/src"
RUN dotnet publish "HelloWorldApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HelloWorldApi.dll"]