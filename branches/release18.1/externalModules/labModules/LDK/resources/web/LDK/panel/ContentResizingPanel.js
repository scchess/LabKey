/**
 * This is designed to help with the problem of rendering dynamic content into Ext4 panels.  It's a little ugly, but this
 * component provides a div into which you render the webpart or report.  On load, it will listen for that element's DOMSubtreeModified/DOMNodeInserted
 * event, and resize the Ext containers if needed.  It attempts to batch these events and only actually trigger a layout when a resize
 * is needed.
 *
 * NOTE: this currently handles the problem by adding DOMSubtreeModified/DOMNodeInserted listeners and manually resizing on change.
 * A more elegant solution would be to dig into Ext's layout engine and make a custom layout that will
 * auto-size itself based on the width of our target element.  We'd need to override the methods that calculate weight and height.
 * Figuring that out will make WebPartPanel work better too.
 */

// The mixin defines the functionality to be used by both the Panel and Component versions below.
Ext4.define('LDK.mixin.ContentResizing', {

    onAfterPanelRender: function() {
        // Room for horizontal scrollbar
        if(Ext4.isDefined(this.overflowX)) {
            this.setHeight(this.getHeight() + 5);
        }
    },

    onContentSizeChange: function(){
        var el = Ext4.get(this.renderTarget);
        var size = el.getSize();
        if (!Ext4.isDefined(this.previousSize) || this.previousSize.height != size.height || this.previousSize.width != size.width){
            this.setSize(size);
            this.previousSize = size;
        }
    },

    createListeners: function(isRetry){
        if (this.doLayout) {
            this.doLayout();
        }

        var el = Ext4.get(this.renderTarget);
        if (!Ext4.isDefined(el) && !isRetry){
            Ext4.defer(this.createListeners, 250, this, [true]);
            return;
        }

        if (Ext4.isIE){
            var cmp = this;

            el = el.query('*[name="webpart"]')[0];
            if (!Ext4.isDefined(el) && !isRetry){
                Ext4.defer(this.createListeners, 250, this, [true]);
                return;
            }

            if (!el && isRetry) {
                return;
            }

            if (el.addEventListener){
                el.addEventListener('DOMSubtreeModified', function(){
                    cmp.fireEvent('contentsizechange');
                }, false);
            }
            else if (el.attachEvent){
                el.attachEvent('DOMSubtreeModified', function(){
                    cmp.fireEvent('contentsizechange');
                });
            }
            else {
                LDK.Utils.logToServer({
                    message: 'Unable to find appropriate event in ContentResizingPanel',
                    level: 'ERROR',
                    includeContext: true
                });
            }
        }
        else if (Ext4.isDefined(el)) {
            el.on('DOMNodeInserted', function(){
                this.fireEvent('contentsizechange');
            }, this);

            // Issue 31454: if the output has a clickable labkey-wp-header, also listen for that event
            Ext4.each(el.query('.labkey-wp-header'), function(wpHeader) {
                Ext4.get(wpHeader).on('click', function(){
                    this.fireEvent('contentsizechange');
                }, this);
            }, this);
        }
    },

    getHeight: function() {
        var el = Ext4.get(this.renderTarget);
        if (Ext4.isDefined(el)) {
            return el.getHeight();
        }
        return this.callParent();
    },

    getWidth: function() {
        var el = Ext4.get(this.renderTarget);
        if (Ext4.isDefined(el)) {
            return el.getWidth();
        }
        return this.callParent();
    }
});

Ext4.define('LDK.panel.ContentResizingPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.ldk-contentresizingpanel',
    divPrefix: 'contentPanel',

    mixins: {
        helper: 'LDK.mixin.ContentResizing'
    },

    constructor: function(config){
        this.mixins.helper.constructor.apply(this, arguments);
        this.callParent([config]);
    },

    initComponent: function () {
        this.renderTarget = this.divPrefix + '-' + Ext4.id();

        Ext4.apply(this, {
            border: false,
            html: '<div class="ldk-wp" id="' + this.renderTarget + '"></div>'
        });

        this.callParent(arguments);

        this.addEvents('contentsizechange');
        this.on('contentsizechange', this.onContentSizeChange, this, {delay: 500, buffer: 500});
        this.on('afterrender', this.onAfterPanelRender, this);
    }
});

Ext4.define('LDK.cmp.ContentResizingComponent', {
    extend: 'Ext.Component',
    alias: 'widget.ldk-contentresizingcmp',
    divPrefix: 'contentComponent',

    mixins: {
        helper: 'LDK.mixin.ContentResizing'
    },

    constructor: function(config){
        this.mixins.helper.constructor.apply(this, arguments);
        this.callParent([config]);
    },

    initComponent: function () {
        this.renderTarget = this.divPrefix + '-' + Ext4.id();

        Ext4.apply(this, {
            border: false,
            html: '<div class="ldk-wp" id="' + this.renderTarget + '"></div>'
        });

        this.callParent(arguments);

        this.addEvents('contentsizechange');
        this.on('contentsizechange', this.onContentSizeChange, this, {delay: 500, buffer: 500});
        this.on('afterrender', this.onAfterPanelRender, this);
    }
});