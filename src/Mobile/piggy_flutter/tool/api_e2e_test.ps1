$ErrorActionPreference = "Stop"
$base = "https://piggyvault.abhith.net"

function Test-Endpoint($Name, $Method, $Url, $Body, $Headers) {
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            ContentType = "application/json"
            UseBasicParsing = $true
        }
        if ($Body) { $params.Body = $Body }
        if ($Headers) { $params.Headers = $Headers }
        $r = Invoke-WebRequest @params
        $json = $r.Content | ConvertFrom-Json
        if (-not $json.success) { throw "API returned success=false for $Name" }
        Write-Output "PASS: $Name"
        return $json
    } catch {
        Write-Output "FAIL: $Name - $_"
        exit 1
    }
}

$tenant = Test-Endpoint "IsTenantAvailable" POST "$base/api/services/app/Account/IsTenantAvailable" '{"tenancyName":"Default"}' $null
$tenantId = $tenant.result.tenantId

$authBody = '{"usernameOrEmailAddress":"admin","password":"123qwe","rememberClient":true}'
$auth = Test-Endpoint "Authenticate" POST "$base/api/TokenAuth/Authenticate" $authBody @{"Piggy-TenantId"="$tenantId"}
$token = $auth.result.accessToken
$headers = @{
    "Authorization" = "Bearer $token"
    "Piggy-TenantId" = "$tenantId"
}

Test-Endpoint "GetCurrentLoginInformations" GET "$base/api/services/app/session/GetCurrentLoginInformations" $null $headers | Out-Null
Test-Endpoint "GetTenantAccounts" GET "$base/api/services/app/account/GetTenantAccounts" $null $headers | Out-Null
Test-Endpoint "GetTenantCategories" GET "$base/api/services/app/Category/GetTenantCategories" $null $headers | Out-Null
Test-Endpoint "GetTransactions" GET "$base/api/services/app/transaction/GetTransactions?" $null $headers | Out-Null
Test-Endpoint "GetSummary" GET "$base/api/services/app/Transaction/GetSummary?duration=month" $null $headers | Out-Null
Test-Endpoint "GetSettings" GET "$base/api/services/app/User/GetSettings" $null $headers | Out-Null
Test-Endpoint "GetCurrencies" GET "$base/api/services/app/currency/GetCurrencies" $null $headers | Out-Null
Test-Endpoint "GetAccountTypes" GET "$base/api/services/app/account/GetAccountTypes" $null $headers | Out-Null
Test-Endpoint "GetCategoryReport" GET "$base/api/services/app/Report/GetCategoryReport?startDate=2024-01-01&endDate=2024-12-31" $null $headers | Out-Null
Test-Endpoint "GetCategoryWiseHistory" GET "$base/api/services/app/Report/GetCategoryWiseTransactionSummaryHistory?numberOfIteration=3&periodOfIteration=month&typeOfTransaction=expense" $null $headers | Out-Null

Write-Output "All API E2E checks passed."
