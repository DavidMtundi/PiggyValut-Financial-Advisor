using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Piggyvault.Authentication.External
{
    public class GoogleAuthProviderApi : ExternalAuthProviderApiBase
    {
        public const string Name = "Google";

        public override async Task<ExternalAuthUserInfo> GetUserInfo(string accessCode)
        {
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", accessCode);

            var response = await client.GetAsync("https://www.googleapis.com/oauth2/v2/userinfo");
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            var user = JObject.Parse(content);

            return new ExternalAuthUserInfo
            {
                Provider = Name,
                ProviderKey = user["id"]?.ToString(),
                Name = user["given_name"]?.ToString(),
                Surname = user["family_name"]?.ToString(),
                EmailAddress = user["email"]?.ToString()
            };
        }
    }
}
