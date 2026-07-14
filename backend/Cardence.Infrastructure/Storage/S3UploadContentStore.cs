using Amazon;
using Amazon.S3;
using Amazon.S3.Model;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class S3UploadContentStore : IUploadContentStore
{
    private readonly IAmazonS3 _client;
    private readonly string _bucket;
    private readonly ILogger<S3UploadContentStore> _logger;

    public S3UploadContentStore(
        IOptions<ObjectStorageOptions> options,
        ILogger<S3UploadContentStore> logger)
    {
        var config = options.Value;
        _bucket = config.Bucket;
        _logger = logger;

        var s3Config = new AmazonS3Config
        {
            ForcePathStyle = true,
        };

        if (!string.IsNullOrWhiteSpace(config.Endpoint))
        {
            s3Config.ServiceURL = config.Endpoint.Trim();
        }
        else if (!string.IsNullOrWhiteSpace(config.Region)
                 && !config.Region.Equals("auto", StringComparison.OrdinalIgnoreCase))
        {
            s3Config.RegionEndpoint = RegionEndpoint.GetBySystemName(config.Region);
        }
        else
        {
            throw new InvalidOperationException(
                "ObjectStorage S3 requires Endpoint or a concrete Region (not 'auto').");
        }

        _client = new AmazonS3Client(config.AccessKeyId, config.SecretAccessKey, s3Config);
    }

    public async Task SaveFileAsync(
        string relativeKey,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var key = NormalizeKey(relativeKey);
        content.Position = 0;

        var request = new PutObjectRequest
        {
            BucketName = _bucket,
            Key = key,
            InputStream = content,
            ContentType = contentType,
            CannedACL = S3CannedACL.PublicRead,
        };

        await _client.PutObjectAsync(request, cancellationToken);
    }

    public async Task<Stream?> OpenReadAsync(
        string relativeKey,
        CancellationToken cancellationToken = default)
    {
        var key = NormalizeKey(relativeKey);
        try
        {
            using var response = await _client.GetObjectAsync(_bucket, key, cancellationToken);
            var memory = new MemoryStream();
            await response.ResponseStream.CopyToAsync(memory, cancellationToken);
            memory.Position = 0;
            return memory;
        }
        catch (AmazonS3Exception ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "S3 read failed for key {Key}", key);
            return null;
        }
    }

    public async Task DeleteMatchingFilesAsync(
        string relativeDirectory,
        string fileNamePrefix,
        CancellationToken cancellationToken = default)
    {
        var prefix = NormalizeKey($"{relativeDirectory.TrimEnd('/')}/{fileNamePrefix}");
        var request = new ListObjectsV2Request
        {
            BucketName = _bucket,
            Prefix = prefix,
        };

        ListObjectsV2Response response;
        do
        {
            response = await _client.ListObjectsV2Async(request, cancellationToken);
            foreach (var entry in response.S3Objects)
            {
                await _client.DeleteObjectAsync(_bucket, entry.Key, cancellationToken);
            }

            request.ContinuationToken = response.NextContinuationToken;
        }
        while (response.IsTruncated == true);
    }

    private static string NormalizeKey(string relativeKey)
    {
        return relativeKey
            .Replace('\\', '/')
            .TrimStart('/');
    }
}
