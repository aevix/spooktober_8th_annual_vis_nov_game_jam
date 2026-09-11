################################################################################
##
## Ripple Transition for Ren'Py
##
################################################################################
## This file includes a shader and Transition class for a ripple transition in
## Ren'Py. It is designed to be used with Ren'Py 7.4.8 or later.
##
## You do not need to read through nor understand this code! Examples of how
## to use this transition are near the top of this file, in the ripple_test
## label. Some sample transition declarations are included also in the
## EXAMPLE TRANSITIONS section. If you'd like to read up more on how it all
## works, the class and shader have been extensively documented below.
##
## If you use this code in your project,
## please credit me as Feniks @ feniksdev.com
## Also consider tossing me a ko-fi @ https://ko-fi.com/fen
################################################################################

########################################################################
## EXAMPLE TRANSITIONS
########################################################################
## You can define as many constants here as you like to make it easy to
## use transition styles you use frequently.
##
## The following arguments can be provided to the Ripple transition class:
## `time`
##     The time the transition will take.
## `center`
##     The position the ripple should ripple outwards from. Either
##     two floats (for screen percentage) or two integers (for pixel
##     positions). May also be "mouse" to center where the mouse is
##     clicked, or "follow" to follow the mouse during the transition.
## `start_ripple_pct`
##     A float from 0.0-1.0. Dictates how many ripples begin on-screen
##     when the transition begins.
## `ripple_density`
##     A float. Smaller numbers make bigger, spread-out ripples, and
##     larger numbers make many smaller ripples. Also takes negative
##     numbers to reverse the direction of the ripples (into the screen
##     instead of outwards). Typically between -100 and 100.
## `ripple_shudder`
##     A float. How much the "noise" is in the ripples. Larger numbers
##     make them shake more as they dip into the screen. Typically
##     between 10-50, but you can try larger or negative numbers
##     for interesting results.
## `center_fade`
##     True if this image should fade in from the center. Otherwise,
##     the whole image fades in uniformly. True by default.
## `time_warp`
##     A function that adjusts the timeline. If not None, this should be a
##     function that takes a fractional time between 0.0 and 1.0, and
##     returns a number in the same range. Can be used to apply an ease to
##     the ripples, for example, instead of linear time.
## `center_warp`
##     A function that adjusts the center of the ripple. If not None, this
##     should be a function that takes a fractional time between 0.0 and
##     1.0 and returns a tuple with two values between 0.0 and 1.0. Can be used
##     to change the center of the ripple over time.
## `screen_ratio`
##     If True (the default), the ripple will be adjusted to accommodate
##     the screen ratio so the ripples will be circular. If False, the
##     ripples will be relative to the size of the screen. Otherwise,
##     you can provide a float which will be used to adjust the aspect
##     ratio of the ripples.


## A pretty standard ripple
define ripple = Ripple(1.5)
## This one starts rippling from the mouse position, but doesn't follow it
## if the player moves the mouse after it's started.
define mouse_ripple = Ripple(2.0, center="mouse", start_ripple_pct=0.25,
    ripple_density=40.0, ripple_shudder=20.0)
## This ripple follows the mouse around during the transition.
define follow_ripple = Ripple(3.0, center="follow", start_ripple_pct=0.3,
    ripple_density=-80.0, center_fade=False)

########################################################################
##
## Example script use
##
########################################################################
## Some example tiled backgrounds constructed out of coloured squares.
## This is so you can visibly see the distortion. You can remove these once
## you've seen the example label.
image bg tile = Tile(Grid(2, 2, Transform("#8db0e0", size=(100, 100)),
    Transform("#b3e2ee", size=(100, 100)), Transform("#b3e2ee", size=(100, 100)),
    Transform("#8db0e0", size=(100, 100))))
image bg tile2 = Tile(Grid(2, 2, Transform("#53a63f", size=(60, 60)),
    Transform("#297e1e", size=(60, 60)), Transform("#297e1e", size=(60, 60)),
    Transform("#53a63f", size=(60, 60))))

## To see these transitions, write "jump ripple_test" somewhere in your script.
## You may remove this code once you no longer need the examples.
label ripple_test():
    scene bg tile2
    show eileen happy
    with ripple
    pause
    hide eileen
    show bg tile
    with mouse_ripple
    pause
    scene bg tile2 with follow_ripple
    pause
    ## You can also use the Ripple transition class
    ## directly and pass it arguments.
    scene bg tile with Ripple(3.0, start_ripple_pct=0.6,
        ripple_density=60.0, ripple_shudder=10.0, center_fade=False)
    pause
    ## You can pass as many or as few as needed; with Ripple(1.0) is also valid.
    scene bg tile2 with Ripple(1.0)
    pause
    jump ripple_test

################################################################################
## BACKEND - DO NOT REMOVE FROM HERE DOWN!
################################################################################
## SHADER
################################################################################
init -50 python:
    ## The shader which is used to create the ripple effect
    renpy.register_shader("feniks.ripple", variables="""
        uniform float u_lod_bias;
        uniform sampler2D tex0;
        uniform sampler2D tex1;

        uniform float u_renpy_time;
        uniform float u_easein_time;
        uniform vec2 u_center;
        uniform float u_start_ripple_pct;
        uniform float u_ripple_density;
        uniform float u_ripple_shudder;
        uniform float u_center_fade;
        uniform float u_screen_ratio;

        uniform vec2 u_model_size;
        varying vec2 v_coords;
        uniform float u_time;
    """, vertex_200="""
        v_coords = vec2(a_position.x / u_model_size.x,
                        a_position.y / u_model_size.y);
    """, fragment_200="""
        // Coordinates of the pixel we're warping, relative to
        // the screen size.
        vec2 uv = v_coords;

        // Aspect ratio to adjust the coordinates by. Used to ensure ripples
        // are circular on rectangular screens.
        vec2 aspect = vec2(u_screen_ratio, 1.0);

        // Adjust the center position by the aspect ratio as well.
        vec2 adj_center = u_center * aspect;

        // Update the coordinates to compensate for the aspect ratio.
        uv *= aspect;

        // Calculate the distance between the coordinates and adjusted center.
        float center_dist = distance(uv, adj_center);
        // Revert the coordinates to their original position.
        uv /= aspect;

        // Get the farthest possible distance from the center part.
        // This farthest point has to finish rippling by the end of the
        // animation.
        float max_dist = max(
            distance(vec2(0.0, 0.0)*aspect, adj_center),
            distance(vec2(0.0, 1.0)*aspect, adj_center));
        max_dist = max(max_dist, distance(vec2(1.0, 0.0)*aspect, adj_center));
        max_dist = max(max_dist, distance(vec2(1.0, 1.0)*aspect, adj_center));

        // Add distortion to the ripples.
        float ripple_wave = 0.08 * sin(center_dist * u_ripple_density
                                        - u_ripple_shudder * u_time);
        // The distance of the main ripple from the center.
        float ripple_dist = u_renpy_time*(u_start_ripple_pct+max_dist);
        // Tell each ripple when to stop rippling.
        float ripple_clamp = clamp(u_start_ripple_pct
                                - abs(ripple_dist - center_dist), 0.0, 1.0)
                                / u_start_ripple_pct;

        // Normalize the offset and add it to the coordinates to
        // distort the screen.
        vec2 offset = normalize(u_center - uv) * ripple_wave * ripple_clamp;
        uv += offset;

        // Fetch the colours from the front & back textures using the adjusted
        // and warped coordinates.
        vec4 color0 = texture2D(tex0, uv, u_lod_bias);
        vec4 color1 = texture2D(tex1, uv, u_lod_bias);

        // Adjust the fade time depending on how far the pixel is
        // from the center of the ripple.
        float mix_time = (u_easein_time) /
            (1.0-((max_dist-center_dist)/max_dist));

        // If u_center_fade is off/False, everything fades in at the
        // same time.
        if (u_center_fade < 0.5) {
            mix_time = u_renpy_time*1.25;
        }
        // Mix time should be between 0 and 1.0 (0-100%)
        mix_time = clamp(mix_time, 0.0, 1.0);

        // Apply the mixed colours to the pixel.
        gl_FragColor = mix(color0, color1, mix_time);

    """)

################################################################################
## TRANSITION CLASS
################################################################################
init -50 python:
    class RippleC(renpy.display.transition.Transition):
        """
        A transition that ripples from the old scene to the new scene.

        `time`
            The time the transition will take.

        `center`
            The position the ripple should ripple outwards from. Either
            two floats (for screen percentage) or two integers (for pixel
            positions). May also be "mouse" to center where the mouse is
            clicked, or "follow" to follow the mouse during the transition.

        `start_ripple_pct`
            A float from 0.0-1.0. Dictates how many ripples begin on-screen
            when the transition begins.

        `ripple_density`
            A float. Smaller numbers make bigger, spread-out ripples, and
            larger numbers make many smaller ripples. Also takes negative
            numbers to reverse the direction of the ripples (into the screen
            instead of outwards). Typically between -100 and 100.

        `ripple_shudder`
            A float. How much the "noise" is in the ripples. Larger numbers
            make them shake more as they dip into the screen. Typically
            between 10-50, but you can try larger or negative numbers
            for interesting results.

        `center_fade`
            True if this image should fade in from the center. Otherwise,
            the whole image fades in uniformly.

        `time_warp`
            A function that adjusts the timeline. If not None, this should be a
            function that takes a fractional time between 0.0 and 1.0, and
            returns a number in the same range.

        `center_warp`
            A function that adjusts the center of the ripple. If not None, this
            should be a function that takes a fractional time between 0.0 and
            1.0 and returns a tuple with two values between 0.0 and 1.0.

        `screen_ratio`
            If True (the default), the ripple will be adjusted to accommodate
            the screen ratio so the ripples will be circular. If False, the
            ripples will be relative to the size of the screen. Otherwise,
            you can provide a float which will be used to adjust the aspect
            ratio of the ripples.
        """

        def __init__(self, time, center=(0.5, 0.5), start_ripple_pct=0.15,
                ripple_density=60.0, ripple_shudder=10.0, center_fade=True,
                time_warp=None, center_warp=None, screen_ratio=True,
                old_widget=None, new_widget=None, alpha=False,
                **properties):
            super(RippleC, self).__init__(time, **properties)

            self.time = time
            self.follow_mouse = False

            if isinstance(center, basestring):
                if center == "follow":
                    self.follow_mouse = True
                if center in ("mouse", "follow"):
                    center = renpy.get_mouse_pos()
                else:
                    raise ValueError("Did not recognize 'center' argument to Ripple transition.")
            if isinstance(center[0], float):
                self.center = center
            else:
                self.center = (float(center[0]/float(config.screen_width)),
                            float(center[1]/float(config.screen_height)))
            self.start_ripple_pct = float(start_ripple_pct)
            self.ripple_density = float(ripple_density)
            self.ripple_shudder = float(ripple_shudder)
            self.center_fade = 1.0 if center_fade else 0.0

            self.old_widget = old_widget
            self.new_widget = new_widget
            self.events = False
            self.alpha = alpha
            self.time_warp = time_warp
            self.center_warp = center_warp

            if screen_ratio is True:
                self.screen_ratio = float(config.screen_width) / float(config.screen_height)
            elif not screen_ratio:
                self.screen_ratio = 1.0
            else:
                self.screen_ratio = screen_ratio

        def render(self, width, height, st, at):
            # Update the center position if following the mouse
            if self.follow_mouse:
                center = renpy.get_mouse_pos()
                self.center = (float(center[0]/float(config.screen_width)),
                            float(center[1]/float(config.screen_height)))

            if renpy.game.less_updates:
                return null_render(self, width, height, st, at)

            # Only show the new image if the transform time is finished
            if st >= self.time:
                self.events = True
                return renpy.render(self.new_widget, width, height, st, at)

            # Calculate the percentage of the transition which is complete
            complete = min(1.0, st / self.time)
            # Calculate easein time for the background fadein
            import math
            easein_time = 1.0 - math.cos(complete * math.pi / 1.68)
            easein_time /= 1.2

            if self.center_warp is not None:
                # Apply the warper to the center
                self.center = self.center_warp(complete)
            if self.time_warp is not None:
                # Apply the warper to the time
                complete = self.time_warp(complete)

            bottom = renpy.render(self.old_widget, width, height, st, at)
            top = renpy.render(self.new_widget, width, height, st, at)

            width = min(top.width, bottom.width)
            height = min(top.height, bottom.height)

            temp_kw = dict()
            if renpy.version(tuple=True) < (7, 5, 0): ## Compatibility
                temp_kw['opaque'] = not config.dissolve_force_alpha
            rv = renpy.display.render.Render(width, height, **temp_kw)

            rv.operation = renpy.display.render.DISSOLVE
            rv.operation_alpha = renpy.config.dissolve_force_alpha
            rv.operation_complete = complete

            if renpy.display.render.models:

                target = rv.get_size()

                if top.get_size() != target:
                    top = top.subsurface((0, 0, width, height))
                if bottom.get_size() != target:
                    bottom = bottom.subsurface((0, 0, width, height))

                rv.mesh = True
                # Add the shader and pass in variables
                rv.add_shader("feniks.ripple")
                rv.add_uniform("u_renpy_time", complete)
                rv.add_uniform("u_easein_time", easein_time)
                rv.add_uniform("u_center", self.center)
                rv.add_uniform("u_start_ripple_pct", self.start_ripple_pct)
                rv.add_uniform("u_ripple_density", self.ripple_density)
                rv.add_uniform("u_ripple_shudder", self.ripple_shudder)
                rv.add_uniform("u_center_fade", self.center_fade)
                rv.add_uniform('u_screen_ratio', self.screen_ratio)
                rv.add_property("mipmap",
                    renpy.config.mipmap_dissolves if (self.style.mipmap
                        is None) else self.style.mipmap)

            rv.blit(bottom, (0, 0), focus=False, main=False)
            rv.blit(top, (0, 0), focus=True, main=True)

            # Render the transition to the screen
            renpy.display.render.redraw(self, 0)

            return rv

    # Curry the transition so it can be used in script
    Ripple = renpy.curry(RippleC)

################################################################################
## Code to archive these files for a distributed game. Do not remove.
init python:
    build.classify("**ripple.rpy", None)
    build.classify("**ripple.rpyc", "archive")
################################################################################
