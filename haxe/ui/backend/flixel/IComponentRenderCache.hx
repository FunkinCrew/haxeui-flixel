package haxe.ui.backend.flixel;

import haxe.ui.core.Component;

/**
 * A render cache for a component.
 **/
interface IComponentRenderCache {
    function drawCached(component:Component):Bool;

    function destroy():Void;
}
