(function(ns){

  ns.BusConst = function(){
    var messageListeners = {};

    var _subscribe = function(msgKey, handler){
      if (!messageListeners[msgKey]) messageListeners[msgKey] = [];
      messageListeners[msgKey].push(handler);
    };

    var _send = function(msgKey, data){
      console.log(msgKey + " sended with " + (data || "nothing"));
      if (!messageListeners[msgKey]) return;
      messageListeners[msgKey].forEach(function(listener){
        listener(data);
      });
    };

    return {
      subscribe: _subscribe,
      send: _send
    }
  };

  return ns;

}( WD || {} ))