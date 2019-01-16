#include <aws/lambda-runtime/runtime.h>

#include <base64.h>

#include "json.hpp"

#include <algorithm>
#include <string>

#include <stdio.h>

using invocation_request = aws::lambda_runtime::invocation_request;
using invocation_response = aws::lambda_runtime::invocation_response;

using json = nlohmann::json;

using string = std::string;

invocation_response example(const invocation_request& request)
{
  const auto payload = json::parse(request.payload);
  const auto body = payload["body"].get<string>();
  auto decoded = base64::decode(body);

  printf("example:\n");
  printf("request body: '%s'\n", body.c_str());
  printf("decoded: '%s'\n", decoded.c_str());

  std::reverse(decoded.begin(), decoded.end());
  string output;
  std::transform(decoded.begin(), decoded.end(), std::back_inserter(output), ::tolower);

  const auto encoded = base64::encode(output);

  printf("output: '%s'\n", output.c_str());
  printf("encoded: '%s'\n", encoded.c_str());


  return invocation_response::success(string{""}
      + "{\"statusCode\": 200"
      + ",\"body\": \"" + encoded + "\""
      + ",\"isBase64Encoded\": true"
      + "}",
    "application/octet-stream"
  );
}

int main()
{
  run_handler(example);
  return 0;
}
