
var _XwebQueues = [];
var _XwebTask = {
    taskid: 0,
    onSuccess: function(){},
    onError: function(){},
    init: function(taskid, onSuccess, onError) {
        this.taskid = taskid;
        this.onSuccess = onSuccess;
        this.onError = onError;
        return this
    }
};
var XwebBridge = {
    call:function(_method,_data,_onSuccess,_onError,_class){
         _data=_data?_data:{};
        _class=_class?_class:'XwebPlugin';
        _onSuccess=_onSuccess?_onSuccess:function(){};
        _onError=_onError?_onError:function(){};
        _XwebQueues.push(_XwebTask.init(_XwebQueues.length, _onSuccess, _onError));
        window.webkit.messageHandlers.XwebBridge.postMessage({
            class:_class,
            method:_method,
            data:_data,
            taskid: _XwebQueues.length - 1
        });
    }
};
var console = { 
    log:function(obj){
        XwebBridge.call('log',{log:obj});
    }
};
var _XwebOnSuccess = function(i, j) {
    _XwebQueues[i].onSuccess(JSON.parse(j));
};
var _XwebOnError = function (i, j) {
    _XwebQueues[i].onError(j);
};
