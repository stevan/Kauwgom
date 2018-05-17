
function main ( req, tmpl_data ) {

    var json = JSON.stringify(
        {
            "ENV"       : req.getEnv(),
            "TMPL_DATA" : tmpl_data
        },
        null, 2
    );

    var resp = req.newResponse();

    resp.setHeaders({
        "Content-Type"   : "text/plain",
        "Content-Length" : json.length,
        "X-Kauwgom"      : Kauwgom.version,
        "X-Kauwgom-Host" : Kauwgom.Host.version,
        "X-Duktape"      : Duktape.version
    });

    resp.setBody([ json ]);

    return resp;
}

Kauwgom.execute( main );

