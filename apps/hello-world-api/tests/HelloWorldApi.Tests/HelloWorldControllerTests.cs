using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using HelloWorldApi.Controllers;
using Moq;

namespace HelloWorldApi.Tests;

public class HelloWorldControllerTests
{
    private readonly Mock<ILogger<HelloWorldController>> _mockLogger;
    private readonly HelloWorldController _controller;

    public HelloWorldControllerTests()
    {
        _mockLogger = new Mock<ILogger<HelloWorldController>>();
        _controller = new HelloWorldController(_mockLogger.Object);
    }

    [Fact]
    public void Get_ReturnsOkResult()
    {
        // Act
        var result = _controller.Get();

        // Assert
        Assert.IsType<OkObjectResult>(result.Result);
    }

    [Fact]
    public void Health_ReturnsHealthyStatus()
    {
        // Act
        var result = _controller.Health();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        dynamic value = okResult.Value;
        Assert.Equal("Healthy", value.GetType().GetProperty("Status").GetValue(value));
    }
}