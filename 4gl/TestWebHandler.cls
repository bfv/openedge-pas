using OpenEdge.Core.*.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.*.

class TestWebHandler inherits WebHandler:

  method override public integer HandleGet(request as OpenEdge.Web.IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable writer as WebResponseWriter no-undo.
    
    response = new WebResponse().
    response:Entity = new String("OK").
    response:ContentType = "text/plain".
    
    writer = new WebResponseWriter(response).
    writer:Open().
    writer:Close().
    
    return 0.
    
  end method.  // HandleGet

  method override protected integer HandleNotAllowedMethod(request as IWebRequest). end.
  method override protected integer HandleNotImplemented(request as IWebRequest). end.

end class.  // TestWebHandler
