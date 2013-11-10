#include <stdlib.h>
#include <stdio.h>

#define TO_STR(args...) (#args)

int
main(int argc, char **argv)
{
    printf("%s\n", TO_STR(
               style "default" {
                   xthickness = 1
                       ythickness        = 1

                       GtkWidget::focus-line-width        = 1
                       GtkMenuBar::window-dragging        = 1
                       GtkToolbar::window-dragging        = 1
                       GtkToolbar::internal-padding        = 4
                       GtkToolButton::icon-spacing     = 4

                       GtkWidget::tooltip-radius       = 3
                       GtkWidget::tooltip-alpha        = 235
                       GtkWidget::new-tooltip-style    = 1

                       GtkSeparatorMenuItem::horizontal-padding = 3
                           GtkSeparatorMenuItem::wide-separators = 1
                           GtkSeparatorMenuItem::separator-height = 1

                           GtkButton::child-displacement-y        = 0
                           GtkButton::default-border        = { 0, 0, 0, 0 }
                       GtkButton::default-outside_border       = { 0, 0, 0, 0 }

                       GtkEntry::state-hint            = 1

                           GtkScrollbar::trough-border        = 0
                           GtkRange::trough-border                = 0
                           GtkRange::slider-width                = 13
                           GtkRange::stepper-size                = 0

                           GtkScrollbar::activate-slider                        = 1
                           GtkScrollbar::has-backward-stepper                = 0
                           GtkScrollbar::has-forward-stepper                = 0
                           GtkScrollbar::min-slider-length                 = 42
                           GtkScrolledWindow::scrollbar-spacing                = 0
                           GtkScrolledWindow::scrollbars-within-bevel        = 1

                           GtkVScale::slider_length         = 16
                           GtkVScale::slider_width         = 16
                           GtkHScale::slider_length         = 16
                           GtkHScale::slider_width         = 17

                           GtkStatusbar::shadow_type        = GTK_SHADOW_NONE
                           GtkSpinButton::shadow_type         = GTK_SHADOW_NONE
                           GtkMenuBar::shadow-type                = GTK_SHADOW_NONE
                           GtkToolbar::shadow-type                = GTK_SHADOW_NONE
                           GtkMenuBar::internal-padding        = 0
                           GtkMenu::horizontal-padding        = 0
                               GtkMenu::vertical-padding        = 0

                               GtkCheckButton::indicator_spacing        = 3
                               GtkOptionMenu::indicator_spacing        = { 8, 2, 0, 0 }

                           GtkTreeView::row_ending_details         = 0
                               GtkTreeView::expander-size                = 11
                               GtkTreeView::vertical-separator                = 4
                               GtkTreeView::horizontal-separator        = 4
                               GtkTreeView::allow-rules                = 1

                               GtkExpander::expander-size              = 11

                               bg[NORMAL]                = @bg_color
                               bg[PRELIGHT]                = shade (1.02, @bg_color)
                               bg[SELECTED]                = @selected_bg_color
                               bg[INSENSITIVE]         = @bg_color
                               bg[ACTIVE]                = shade (0.9, @bg_color)

                               fg[NORMAL]                = @text_color
                               fg[PRELIGHT]                = @fg_color
                               fg[SELECTED]                = @selected_fg_color
                               fg[INSENSITIVE]                = darker (@bg_color)
                               fg[ACTIVE]                = @fg_color

                               text[NORMAL]                = @text_color
                               text[PRELIGHT]                = @text_color
                               text[SELECTED]                = @selected_fg_color
                               text[INSENSITIVE]        = darker (@bg_color)
                               text[ACTIVE]                = @selected_fg_color

                               base[NORMAL]                = @base_color
                               base[PRELIGHT]                = shade (0.95, @bg_color)
                               base[SELECTED]                = @selected_bg_color
                               base[INSENSITIVE]        = @bg_color
                               base[ACTIVE]                = shade (0.9, @selected_bg_color)

                               engine "pixmap"
                               {

                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = NORMAL
                           shadow                          = OUT
                           overlay_file                    = "Check-Radio/checkbox-unchecked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = PRELIGHT
                           shadow                          = OUT
                           overlay_file                    = "Check-Radio/checkbox-unchecked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = ACTIVE
                           shadow                          = OUT
                           overlay_file                    = "Check-Radio/checkbox-unchecked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = SELECTED
                           shadow                          = OUT
                           overlay_file                    = "Check-Radio/checkbox-unchecked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = INSENSITIVE
                           shadow                          = OUT
                           overlay_file                    = "Check-Radio/checkbox-unchecked-insensitive.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = NORMAL
                           shadow                          = IN
                           overlay_file                    = "Check-Radio/checkbox-checked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                 = PRELIGHT
                           shadow                          = IN
                           overlay_file                    = "Check-Radio/checkbox-checked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = ACTIVE
                           shadow                          = IN
                           overlay_file                    = "Check-Radio/checkbox-checked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = SELECTED
                           shadow                          = IN
                           overlay_file                    = "Check-Radio/checkbox-checked.png"
                           overlay_stretch                 = FALSE
                           }
                   image
                   {
                       function                        = CHECK
                           recolorable                     = TRUE
                           state                         = INSENSITIVE
                           shadow                          = IN
                           overlay_file                = "Check-Radio/checkbox-checked-insensitive.png"
                           overlay_stretch                 = FALSE
                           }

                   image
                   {
                   function                        = OPTION
                       state                         = NORMAL
                       shadow                          = OUT
                       overlay_file                    = "Check-Radio/option-unchecked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = PRELIGHT
                       shadow                          = OUT
                       overlay_file                    = "Check-Radio/option-unchecked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = ACTIVE
                       shadow                          = OUT
                       overlay_file                    = "Check-Radio/option-unchecked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = SELECTED
                       shadow                          = OUT
                       overlay_file                    = "Check-Radio/option-unchecked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = INSENSITIVE
                       shadow                         = OUT
                       overlay_file                    = "Check-Radio/option-unchecked-insensitive.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = NORMAL
                       shadow                          = IN
                       overlay_file                    = "Check-Radio/option-checked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                        = PRELIGHT
                       shadow                          = IN
                       overlay_file                    = "Check-Radio/option-checked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                        = ACTIVE
                       shadow                          = IN
                       overlay_file                    = "Check-Radio/option-checked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                        = SELECTED
                       shadow                          = IN
                       overlay_file                    = "Check-Radio/option-checked.png"
                       overlay_stretch                 = FALSE
                       }
                   image
                   {
                   function                        = OPTION
                       state                         = INSENSITIVE
                       shadow                          = IN
                       overlay_file                    = "Check-Radio/option-checked-insensitive.png"
                       overlay_stretch                 = FALSE
                       }

                   image
                   {
                       function                        = ARROW
                           overlay_file                = "Arrows/arrow-up.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = UP
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = PRELIGHT
                           overlay_file                = "Arrows/arrow-up-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = UP
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = ACTIVE
                           overlay_file                = "Arrows/arrow-up-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = UP
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = INSENSITIVE
                           overlay_file                = "Arrows/arrow-up-insens.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = UP
                           }


                   image
                   {
                       function                        = ARROW
                           state                        = NORMAL
                           overlay_file                = "Arrows/arrow-down.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = DOWN
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = PRELIGHT
                           overlay_file                = "Arrows/arrow-down-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = DOWN
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = ACTIVE
                           overlay_file                = "Arrows/arrow-down-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = DOWN
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = INSENSITIVE
                           overlay_file                = "Arrows/arrow-down-insens.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = DOWN
                           }

                   image
                   {
                       function                        = ARROW
                           overlay_file                = "Arrows/arrow-left.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = LEFT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = PRELIGHT
                           overlay_file                = "Arrows/arrow-left-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = LEFT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = ACTIVE
                           overlay_file                = "Arrows/arrow-left-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = LEFT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = INSENSITIVE
                           overlay_file                = "Arrows/arrow-left-insens.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = LEFT
                           }

                   image
                   {
                       function                        = ARROW
                           overlay_file                = "Arrows/arrow-right.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = RIGHT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = PRELIGHT
                           overlay_file                = "Arrows/arrow-right-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = RIGHT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = ACTIVE
                           overlay_file                = "Arrows/arrow-right-prelight.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = RIGHT
                           }
                   image
                   {
                       function                        = ARROW
                           state                        = INSENSITIVE
                           overlay_file                = "Arrows/arrow-right-insens.png"
                           overlay_border                = { 0, 0, 0, 0 }
                       overlay_stretch                = FALSE
                           arrow_direction                = RIGHT
                           }


                   image
                   {
                   function                    = TAB
                       state                        = INSENSITIVE
                       overlay_file                = "Arrows/arrow-down-insens.png"
                       overlay_stretch                = FALSE
                       }
                   image
                   {
                   function                        = TAB
                       state                        = NORMAL
                       overlay_file                = "Arrows/arrow-down.png"
                       overlay_border                = { 0, 0, 0, 0 }
                   overlay_stretch                = FALSE
                       }
                   image
                   {
                   function                        = TAB
                       state                        = PRELIGHT
                       overlay_file                = "Arrows/arrow-down-prelight.png"
                       overlay_border                = { 0, 0, 0, 0 }
                   overlay_stretch                = FALSE
                       }

                   image
                   {
                       function                        = VLINE
                           file                        = "Lines/line-v.png"
                           border                        = { 0, 0, 0, 0 }
                       stretch                        = TRUE
                           }
                   image
                   {
                       function                        = HLINE
                           file                        = "Lines/line-h.png"
                           border                        = { 0, 0, 0, 0 }
                       stretch                        = TRUE
                           }

                   image
                   {
                   function                    = FOCUS
                       file                        = "Others/focus.png"
                       border                        = { 1, 1, 1, 1 }
                   stretch                        = TRUE
                       }

                   image
                   {
                       function                        = HANDLE
                           overlay_file                = "Handles/handle-h.png"
                           overlay_stretch                = FALSE
                           orientation                        = HORIZONTAL
                           }
                   image
                   {
                       function                        = HANDLE
                           overlay_file                = "Handles/handle-v.png"
                           overlay_stretch                = FALSE
                           orientation                        = VERTICAL
                           }

                   image
                   {
                   function                    = EXPANDER
                       expander_style                = COLLAPSED
                       file                        = "Expanders/plus.png"
                       }

                   image
                   {
                   function                    = EXPANDER
                       expander_style              = EXPANDED
                       file                        = "Expanders/minus.png"
                       }

                   image
                   {
                   function                    = EXPANDER
                       expander_style                = SEMI_EXPANDED
                       file                        = "Expanders/minus.png"
                       }

                   image
                   {
                   function                    = EXPANDER
                       expander_style                = SEMI_COLLAPSED
                       file                        = "Expanders/plus.png"
                       }

                   image
                   {
                   function                    = RESIZE_GRIP
                       state                        = NORMAL
                       detail                        = "statusbar"
                       overlay_file                = "Others/null.png"
                       overlay_border                = { 0,0,0,0 }
                   overlay_stretch             = FALSE
                       }

                   image
                   {
                       function                        = SHADOW_GAP
                           file                        = "Others/null.png"
                           border                        = { 4, 4, 4, 4 }
                       stretch                        = TRUE
                           }

               }
               }
        ));
    return 0;
}
