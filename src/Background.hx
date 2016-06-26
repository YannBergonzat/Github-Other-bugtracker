package ;

import chrome.Runtime;
import chrome.Tabs;
import chrome.Windows;
import com.barth.gob.ElementId;
import com.barth.gob.extend.RuntimeResponse;
import com.barth.gob.Method;
import js.Browser;

class Background {

    private var _tabId:Array<Int>;
    static function main():Void{
        new Background();
    }

    public function new():Void{
        if(Browser.getLocalStorage().getItem(ElementId.OPTION_PAGE_VIEW_KEY) == null ||
            Browser.getLocalStorage().getItem(ElementId.BUGTRACKER_URL_KEY) == null ||
            Browser.getLocalStorage().getItem(ElementId.BUGTRACKER_URL_KEY) == ""  ||
            Browser.getLocalStorage().getItem(ElementId.USE_RELEASE_KEY) == null) {
            Runtime.openOptionsPage();
        }
        RuntimeResponse.onMessage.addListener(messageListenerHandler);
    }

    private function messageListenerHandler(?request:Dynamic, sender:MessageSender, ?sendResponse:Dynamic->Void):Void{
        switch (request.method) {
            case Method.GET_BUGTRACKER_URL :
                var bugtrackerIssueUrl:String = Browser.getLocalStorage().getItem(ElementId.BUGTRACKER_URL_KEY);
                sendResponse({url:bugtrackerIssueUrl});
            case Method.SET_BUGTRACKER_URL :
                Browser.getLocalStorage().setItem(ElementId.BUGTRACKER_URL_KEY, request.url);
                sendResponse({success:true});
            case Method.SET_OPTION_PAGE_VIEW:
                Browser.getLocalStorage().setItem(ElementId.OPTION_PAGE_VIEW_KEY, "true");
            case Method.GET_USE_RELEASE:
                var useRelease:Bool = cast (Browser.getLocalStorage().getItem(ElementId.USE_RELEASE_KEY));
                sendResponse({'checked':useRelease});
            case Method.SET_USE_RELEASE:
                Browser.getLocalStorage().setItem(ElementId.USE_RELEASE_KEY, request.url);
            case Method.OPTION_CHANGED:
                Tabs.query({windowType:WindowType.normal, active:true},function(tab){
                    Tabs.sendMessage(tab[0].id, {method:Method.OPTION_CHANGED}, function(Response:Dynamic){});
                });
            default:
                trace('unknow message :'+ request.method);
        }
    }

}
