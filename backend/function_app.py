import json
import os
import azure.functions as func
from azure.data.tables import TableClient, UpdateMode

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route="visitor-count", methods=["GET"])
def visitor_count(req):
    connection_string = os.environ["AZURE_TABLE_CONNECTION_STRING"]
    table_client = TableClient.from_connection_string(
        conn_str=connection_string,
        table_name="VisitorCounter"
    )

    counter = table_client.get_entity(
        partition_key="site",
        row_key="main"
    )

    count_value = counter["Count"]
    if hasattr(count_value, "value"):
        count_value = count_value.value

    current_count = int(count_value)
    new_count = current_count + 1
    counter["Count"] = new_count

    table_client.update_entity(
        entity=counter,
        mode=UpdateMode.REPLACE
    )

    response_body = {
        "visitor_count": new_count
    }

    return func.HttpResponse(
        json.dumps(response_body),
        mimetype="application/json"
    )
