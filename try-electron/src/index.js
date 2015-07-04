'use strict';

var remote = require('remote');
var test = remote.require('./test');

new Vue({
    el: '#app',
    data: {
        initialized: false,
        message: "electron & vue.js",
        response: null,
        input_text: ''
    },
    created: function() {
        var self = this;
        $.ajax({type: 'GET', url: 'http://httpbin.org/get', dataType: 'json'})
            .done(function(data) {
                self.response = data;
                self.initialized = true;
            });
        // NOTE: remote calling test
        console.log("add (remote): " + test.add(1, 2));
    }
});
