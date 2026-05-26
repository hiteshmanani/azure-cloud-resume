import json
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route="visitor-count", methods=["GET"])
def visitor_count(req):
    response_body = {
        "visitor_count": 0
    }

    return func.HttpResponse(
        json.dumps(response_body),
        mimetype="application/json"
    )
