var Vue = require('vue');
var director = require('director');
var $ = require('jquery')

$(function() {
    var ajax_alert = function(_, _, err) {
        alert(err);
    };

    Vue.component('all', {
        template: require('./components/all.html')
    });
    Vue.component('dummy', {
        template: require('./components/dummy.html')
    });

    var app = new Vue({
        el: '#memo-app',
        data: {
            title: 'Memo List',
            memos: [],
            newMemo: {
                content: ''
            },
            currentView: 'all'
        },
        methods: {
            postMemo: function() {
                var json = JSON.stringify(app.newMemo);
                $.ajax({ type: 'POST'
                       , url: '/memos'
                       , data: json
                       , contentType: 'application/json'
                       , dataType: 'json'
                       })
                    .done(function(stored) {
                        app.memos.push({ id: stored.id, content: stored.memo.content });
                        app.newMemo.content = '';
                    })
                    .fail(ajax_alert);
            },
            deleteMemo: function(memo) {
                $.ajax({type: 'DELETE', url: '/memos/'+memo.id})
                    .done(function() {
                        app.memos.splice(memo.$index, 1);
                    })
                    .fail(ajax_alert);
            }
        }
    });

    director.Router({
        'all': function() { app.currentView = 'all'; },
        'dummy': function() { app.currentView = 'dummy'; }
    })
    .init();

    $.ajax({type: 'GET', url: '/memos', dataType: 'json'})
        .done(function(data) {
            $.each(data, function() {
                var stored = this;
                app.memos.push({ id: stored.id, content: stored.memo.content });
            });
        })
        .fail(ajax_alert);
});
