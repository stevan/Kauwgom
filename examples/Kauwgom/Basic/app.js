
function main ( req, tmpl_data ) {

    if ( req.requestMethod() != 'GET' ) {
        var body = 'Method '+req.requestMethod()+' not allowed\n';
        return req.newResponse(
            405,
            {
                "Content-Type" : "text/plain",
                "Content-Length" : body.length
            },
            [ body ]
        );
    }

    var json = JSON.stringify(
        {
            "ENV"       : req.getEnv(),
            "TMPL_DATA" : tmpl_data,
            "Test-Data" : [ 1, 2, 3 ].map(function (x) { return x + 10 })
        },
        null, 2
    );

    var resp = req.newResponse();
    resp.setHeaders({
        "Content-Type"   : "application/json",
        "Content-Length" : json.length,
        "X-Kauwgom"      : Kauwgom.version,
        "X-Kauwgom-Host" : Kauwgom.Host.version,
        "X-Duktape"      : Duktape.version
    });
    resp.setBody([ json ]);

    return resp;
}

