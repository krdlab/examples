import js.JQuery;

class App {
    static function main() {
        new JQuery(js.Browser.window).ready(init);
    }
    static inline function jq(arg) : JQuery {
        return new JQuery(arg);
    }
    static function init(e) {
        var input = jq("<input />");
        var p     = jq("<p />");

        jq("body")
            .append(
                jq("<div />")
                    .append(jq("<span />").text("Name: "))
                    .append(input)
            )
            .append(
                p.css("color", "red")
            );

        input.keyup(function(e) {
            var name = input.val();
            p.text("Hello, " + name);
        });
    }
}
