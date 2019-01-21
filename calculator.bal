import ballerina/http;
import ballerina/log;
import ballerinax/kubernetes;

type Operand "+"|"-"|"*"|"/";

type Operation record {
    float leftSide = 0;
    float rightSide = 0;
    Operand operand?;
    !...
};

type Request record {
    float? leftSide;
    float? rightSide;
};

@kubernetes:Deployment {
    image: "calculator:v.1.0",
    dockerHost: "tcp://192.168.99.100:2376", 
    dockerCertPath: "/Users/rkovacs/.minikube/certs"
}
@http:ServiceConfig {
    basePath: "/calculator"
}
@kubernetes:Service {
    serviceType: "NodePort"
}
service calculator on new http:Listener(9090) {

    resource function multiply(http:Caller caller, http:Request request) {
        http:Response response = new;
        float|error result = multiply(request);
        if (result is float) {
            response.setTextPayload(untaint string.convert(result));
        } else if (result is error) {
            response.setTextPayload(untaint result.reason());
        }
        _ = caller -> respond(response);
    }
}

function multiply(http:Request request) returns float|error {
    json message = check request.getJsonPayload();
    log:printInfo(string `Multiply: {{ message.toString() }}`);
    Request req = check Request.convert(message);
    Operation operation = check Operation.convert(req);
    operation.operand = "*";
    return do(operation);
}

function do(Operation operation) returns float {
    match operation.operand {
        "+" => return operation.leftSide + operation.rightSide;
        "-" => return operation.leftSide - operation.rightSide;
        "*" => return operation.leftSide * operation.rightSide;
        "/" => return operation.leftSide / operation.rightSide;
        _ => return 0.0;
    }
}