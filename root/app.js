
function main ( env ) {
    var req  = new Kauwgom.Request( env );
    var json = JSON.stringify( req.getEnv(), null, 2 );
    var resp = new Kauwgom.Response(
        200,
        {
            "Content-Type"    : "text/plain",
            "Content-Length"  : json.length,
            "X-Kauwgom"      : Kauwgom.version,
            "X-Kauwgom-Host" : Kauwgom.Host.version,
            "X-Duktape"       : Duktape.version
        },
        [
            json
        ]
    );
    return resp;
}

Kauwgom.execute( main );

