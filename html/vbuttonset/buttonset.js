(function ($) {
    $.widget("srt.vbuttonset", {
        version: "0.0.1",
        options: {
            items: "button, input[type=button], input[type=submit], input[type=reset], input[type=checkbox], input[type=radio], a, :data(button)"
        },
        _create: function () {
            this.element.addClass("srt-vbuttonset");
        },
        _init: function () {
            this.refresh();
        },
        _setOption: function (key, value) {
            if (key === "disabled") {
                this.buttons.button("option", key, value);
            }
            this._super(key, value);
        },
        refresh: function () {
            this.buttons = this.element.find(this.options.items)
                .filter(":ui-button")
                .button("refresh")
                .end()
                .not(":ui-button")
                .button()
                .end()
                .map(function () {
                    return $(this).button("widget")[0];
                })
                .removeClass("ui-corner-all ui-corner-top ui-corner-bottom")
                .filter(":first")
                .addClass("ui-corner-top")
                .end()
                .filter(":last")
                .addClass("ui-corner-bottom")
                .addClass("srt-button-last")
                .end()
                .end();
        },

        _destroy: function () {
            this.element.removeClass( "srt-vbuttonset" );
            this.buttons
                .map(function () {
                    return $(this).button("widget")[ 0 ];
                })
                .removeClass("ui-corner-left ui-corner-right")
                .end()
                .button("destroy");
        }
    });
}(jQuery));

$(function () {
    $("#menu").vbuttonset();
    $("#menu").menu();
    $("#menu-container")
        .addClass("ui-helper-clearfix")
        .addClass("srt-menu")
        .height(100);
});
