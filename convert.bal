import ballerina/http;
import ballerina/io;

http:Client simpleEndpoint = new("http://localhost:9091/exchangeSimple/getRate");
http:Client enterpriseEndpoint = new("http://localhost:9092/exchangeEnterprise/getRate", config = {
    retryConfig: {
        interval: 3000,
        count: 2,
        backOffFactor: 2.0,
        maxWaitInterval: 20000
    },
    timeoutMillis: 500
});

public function main(int amount, string currency) {
    float[] rates = collectExchangeRates(currency);
    float max = rates.max();
    
    io:println(multiply(untaint <float>amount, max));
}

function fetchExchangeRate(http:Client clientEndpoint, string currency) returns json|error {
    http:Request req = new;
    req.setPayload(currency);
    http:Response|error response = clientEndpoint->post("", req);
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        return msg!rate;
    }
    error err = error("Unable to fetch exchange rate");
    panic(err);
}

function collectExchangeRates(string currency) returns float[] {
    fork {
        worker w1 returns json|error {
            return trap fetchExchangeRate(simpleEndpoint, currency);
        }
        worker w2 returns json|error {
            return trap fetchExchangeRate(enterpriseEndpoint, currency);
        }
    }
    record{ json|error w1; json|error w2; } results = wait { w1, w2 };
    
    float[] rates = [];
    foreach var w in results {
        var (_, result) = w;
        if (result is float) {
            rates[rates.length()] = result;
        }
    }
    return rates;
}

http:Client calculatorEndpoint = new("http://localhost:9090/calculator");

function multiply(float leftSide, float rightSide) returns string|error {
    http:Request req = new;
    req.setJsonPayload({ leftSide: leftSide, rightSide: rightSide });
    http:Response|error response = calculatorEndpoint->post("/multiply", req);
    if (response is http:Response) {
        return check response.getTextPayload();
    }
    error err = error("Unable to call calculator service");
    panic(err);
}