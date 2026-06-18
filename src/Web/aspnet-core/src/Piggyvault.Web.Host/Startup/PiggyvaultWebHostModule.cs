using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Piggyvault.Authentication.External;
using Piggyvault.Configuration;

namespace Piggyvault.Web.Host.Startup
{
    [DependsOn(
       typeof(PiggyvaultWebCoreModule))]
    public class PiggyvaultWebHostModule: AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public PiggyvaultWebHostModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(PiggyvaultWebHostModule).GetAssembly());
        }

        public override void PostInitialize()
        {
            ConfigureExternalAuthProviders();
        }

        private void ConfigureExternalAuthProviders()
        {
            if (!bool.TryParse(_appConfiguration["Authentication:Google:IsEnabled"], out var enabled) ||
                !enabled)
            {
                return;
            }

            var clientId = _appConfiguration["Authentication:Google:ClientId"];
            var clientSecret = _appConfiguration["Authentication:Google:ClientSecret"];

            if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(clientSecret))
            {
                return;
            }

            var externalAuthConfiguration = IocManager.Resolve<IExternalAuthConfiguration>();
            externalAuthConfiguration.Providers.Add(
                new ExternalLoginProviderInfo(
                    GoogleAuthProviderApi.Name,
                    clientId,
                    clientSecret,
                    typeof(GoogleAuthProviderApi)
                )
            );
        }
    }
}
