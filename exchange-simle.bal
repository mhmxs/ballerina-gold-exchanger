import ballerina/http;
import ballerina/log;

service exchangeSimple on new http:Listener(9091) {

    resource function getRate(http:Caller caller, http:Request request) {
        log:printInfo("Request accepted");
        json message = generateResponse(request.getTextPayload());
        log:printInfo(message.toString());
        http:Response response = new;
        response.setJsonPayload(message);
        _ = caller -> respond(response);
    }
}

function generateResponse(string|error payload) returns @untainted json {
    return payload is string
        ? { currency: payload, rate: getExchangeRate(payload) }
        : { "error": string `Invalid currency: {{payload.reason()}}` };
}

function getExchangeRate(string currency) returns float {
    log:printInfo(string `Looking for currency {{currency}}`);
    match currency {
        "USD"|"EUR" => return 35.50;
        "GBP" => return 32.00;
        _ => return -1;
    }
}