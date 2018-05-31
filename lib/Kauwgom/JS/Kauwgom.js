
// ===================================================== //

if ( Kauwgom == undefined ) var Kauwgom = {};

Kauwgom.version = '0.0.0';

// ----------------------------------------------------- //
// Kauwgom Host environment
// ----------------------------------------------------- //

// to be filled in by the host environment
Kauwgom.Host = {
    'name'    : null,
    'version' : null,
    'channels' : {
        'INPUT'  : function () { throw new Error('You must define the host INPUT channel')  },
        'OUTPUT' : function () { throw new Error('You must define the host OUTPUT channel') },
    },
};

// ----------------------------------------------------- //
// Kauwgom application runner, this assumed the presence
// of a `main` function in the global namespace.
// ----------------------------------------------------- //

Kauwgom.__RUN_MAIN__ = function () {
    var input = Kauwgom.Host.channels.INPUT();
    var req   = new Kauwgom.Request( input.env );
    var resp  = main( req, input.tmpl_data );
    Kauwgom.Host.channels.OUTPUT( resp.finalize() );
}

// ----------------------------------------------------- //
// Kauwgom Request object
// ----------------------------------------------------- //

Kauwgom.Request = function (env) {
    this.env = env;
}

Kauwgom.Request.prototype.getEnv = function () { return this.env }

// Server methods
Kauwgom.Request.prototype.serverProtocol = function () { return this.env['SERVER_PROTOCOL'] }
Kauwgom.Request.prototype.serverName     = function () { return this.env['SERVER_NAME']     }
Kauwgom.Request.prototype.serverPort     = function () { return this.env['SERVER_PORT']     }

// URI methods
Kauwgom.Request.prototype.pathInfo   = function () { return this.env['PATH_INFO']   }
Kauwgom.Request.prototype.scriptName = function () { return this.env['SCRIPT_NAME'] }
Kauwgom.Request.prototype.requestUri = function () { return this.env['REQUEST_URI'] }

// Request methods
Kauwgom.Request.prototype.requestMethod = function () { return this.env['REQUEST_METHOD'] }
Kauwgom.Request.prototype.remoteAddr    = function () { return this.env['REMOTE_ADDR']    }
Kauwgom.Request.prototype.remotePort    = function () { return this.env['REMOTE_PORT']    }
Kauwgom.Request.prototype.queryString   = function () { return this.env['QUERY_STRING']   }

// Headers
Kauwgom.Request.prototype.getHeaderValueFor = function (name) {
    // 'User-Agent' => [ 'User', 'Agent' ]
    var parts = name.split('-');
    // [ 'User', 'Agent' ] => [ 'HTTP', 'User', 'Agent' ]
    parts.unshift('HTTP');
    // [ 'HTTP', 'User', 'Agent' ] => 'HTTP_USER_AGENT'
    var headerName = parts.map(function (x) { return x.toUpperCase() }).join('_');
    return this.env[headerName];
}

Kauwgom.Request.prototype.newResponse = function (status, headers, body) {
    return new Kauwgom.Response(status, headers, body);
}

// ----------------------------------------------------- //
// Kauwgom Response object
// ----------------------------------------------------- //

Kauwgom.Response = function (status, headers, body) {
    this.status  = status  || 200;
    this.headers = headers || {};
    this.body    = body    || [];
}

Kauwgom.Response.prototype.setStatus  = function (status)  { this.status  = status  }
Kauwgom.Response.prototype.setHeaders = function (headers) { this.headers = headers }
Kauwgom.Response.prototype.setBody    = function (body)    { this.body    = body    }

Kauwgom.Response.prototype.getStatus  = function () { return this.status  }
Kauwgom.Response.prototype.getHeaders = function () { return this.headers }
Kauwgom.Response.prototype.getBody    = function () { return this.body    }

Kauwgom.Response.prototype.finalize = function () {
    return [ this.status, this.headers, this.body ];
}

// ===================================================== //

