package haxe.ui.backend.flixel;

import flixel.math.FlxRect;
import flixel.text.FlxText;

/**
 * A high-resolution FlxText that scales with the game's resolution while maintaining sharpness.
 */
class HiResFlxText extends FlxText {
    /**
     * How many screen pixels one game pixel covers. Every HiResFlxText follows this the next time it draws.
     */
    public static var resolution(default, set):Float = 1;

    static function set_resolution(value:Float):Float {
        if (value < 1 || Math.isNaN(value)) value = 1;
        return resolution = value;
    }

    var appliedResolution:Float = 1;
    var logicalSize:Float = 8;
    var logicalBorder:Float = 1;
    var logicalFieldWidth:Float = 0;
    var logicalFieldHeight:Float = 0;

    /**
     * Whether the text field was sized with `setFieldSize`, which keeps auto sizing on.
     */
    var directFieldSize:Bool = false;

    public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true) {
        super(x, y, fieldWidth, text, size, embeddedFont);
        origin.set(0, 0);
    }

    /**
     * Size the text field directly, in game pixels, without changing auto sizing or word wrap.
     */
    public function setFieldSize(width:Float, height:Float):Void {
        directFieldSize = true;
        logicalFieldWidth = width;
        logicalFieldHeight = height;
        textField.width = Math.max(1, width * appliedResolution);
        textField.height = Math.max(1, height * appliedResolution);
        _regen = true;
    }

    /**
     * The size of the text itself, in game pixels.
     */
    public var logicalTextWidth(get, never):Float;

    function get_logicalTextWidth():Float {
        return textField.textWidth / appliedResolution;
    }

    public var logicalTextHeight(get, never):Float;

    function get_logicalTextHeight():Float {
        return textField.textHeight / appliedResolution;
    }

    override function set_size(value:Int):Int {
        logicalSize = value;
        super.set_size(Std.int(Math.max(1, Math.round(value * appliedResolution))));
        return value;
    }

    override function set_borderSize(value:Float):Float {
        logicalBorder = value;
        super.set_borderSize(value * appliedResolution);
        return value;
    }

    override function set_fieldWidth(value:Float):Float {
        directFieldSize = false;
        logicalFieldWidth = value;
        super.set_fieldWidth(value > 0 ? value * appliedResolution : value);
        return value;
    }

    override function get_fieldWidth():Float {
        return (textField != null) ? textField.width / appliedResolution : 0;
    }

    override function set_fieldHeight(value:Float):Float {
        logicalFieldHeight = value;
        super.set_fieldHeight(value > 0 ? value * appliedResolution : value);
        return value;
    }

    override function get_fieldHeight():Float {
        return (textField != null) ? textField.height / appliedResolution : 0;
    }

    function applyResolution():Void {
        if (appliedResolution == resolution) return;
        appliedResolution = resolution;

        super.set_size(Std.int(Math.max(1, Math.round(logicalSize * appliedResolution))));
        super.set_borderSize(logicalBorder * appliedResolution);
        if (directFieldSize) {
            textField.width = Math.max(1, logicalFieldWidth * appliedResolution);
            textField.height = Math.max(1, logicalFieldHeight * appliedResolution);
        } else {
            if (logicalFieldWidth > 0) textField.width = logicalFieldWidth * appliedResolution;
            if (logicalFieldHeight > 0) textField.height = logicalFieldHeight * appliedResolution;
        }
        _regen = true;
    }

    override function regenGraphic():Void {
        applyResolution();
        super.regenGraphic();
        // The hitbox stays in game pixels.
        width = frameWidth / appliedResolution;
        height = frameHeight / appliedResolution;
    }

    override public function draw():Void {
        applyResolution();
        origin.set(0, 0);
        scale.set(1 / appliedResolution, 1 / appliedResolution);
        super.draw();
    }

    override function set_clipRect(rect:FlxRect):FlxRect {
        // Clip rects are in frame pixels, which are `appliedResolution` times larger than game pixels.
        if (rect != null && appliedResolution != 1) {
            rect = FlxRect.get(rect.x * appliedResolution, rect.y * appliedResolution, rect.width * appliedResolution, rect.height * appliedResolution);
        }
        return super.set_clipRect(rect);
    }
}
