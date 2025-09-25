using Yarp.ReverseProxy.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

builder.Services.AddHealthChecks();

var app = builder.Build();


// Custom middleware to log request URL
app.Use(async (context, next) =>
{
    Console.WriteLine($"Test_Request URL: {context.Request.Path + context.Request.QueryString}");
    await next();
});

app.UseRouting();

app.MapHealthChecks("/health");

app.MapReverseProxy();

app.Run();