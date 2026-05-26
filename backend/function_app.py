import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route="visitor-count", methods=["GET"])
def visitor_count(req):
    return func.HttpResponse("Visitor counter API is running")
