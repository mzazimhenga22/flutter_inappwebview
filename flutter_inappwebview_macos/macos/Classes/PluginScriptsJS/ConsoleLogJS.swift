//
//  ConsoleLogJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class ConsoleLogJS {
    
    public static let CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT"
    
    public static func CONSOLE_LOG_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?, forMainFrameOnly: Bool) -> PluginScript {
        return PluginScript(
            groupName: CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: CONSOLE_LOG_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: forMainFrameOnly,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: true,
            messageHandlerNames: ["consoleLog", "consoleDebug", "consoleError", "consoleInfo", "consoleWarn"])
    }
    
    // the message needs to be concatenated with '' in order to have the same behavior like on Android
    public static func CONSOLE_LOG_JS_SOURCE() -> String {
        return """
        (function(console) {
        
            function _callHandler(logLevel, args) {
                var message = '';
                for (var i in args) {
                    try {
                        message += message === '' ? args[i] : ' ' + args[i];
                    } catch(ignored) {}
                }
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onConsoleMessage', {'level': logLevel, 'message': message})
            }
        
            var oldLogs = {
                'consoleLog': console.log,
                'consoleDebug': console.debug,
                'consoleError': console.error,
                'consoleInfo': console.info,
                'consoleWarn': console.warn
            };
        
            for (var k in oldLogs) {
                (function(oldLog) {
                    var logLevel = oldLog.replace('console', '').toLowerCase();
                    console[logLevel] = function() {
                        oldLogs[oldLog].apply(null, arguments);
                        _callHandler(logLevel, arguments);
                    }
                })(k);
            }
        })(window.console);
        """
    }
}
