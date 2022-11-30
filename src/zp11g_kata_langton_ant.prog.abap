REPORT zp11g_kata_langton_ant NO STANDARD PAGE HEADING LINE-SIZE 1000.
"https://en.wikipedia.org/wiki/Langton%27s_ant
"https://datagenetics.com/blog/september22015/index.html

CLASS ant DEFINITION.
  PUBLIC SECTION.
    TYPES     direction TYPE c LENGTH 1.
    CONSTANTS dir_north TYPE direction VALUE 'N'.
    CONSTANTS dir_east  TYPE direction VALUE 'E'.
    CONSTANTS dir_south TYPE direction VALUE 'S'.
    CONSTANTS dir_west  TYPE direction VALUE 'W'.

    METHODS constructor
      IMPORTING
        width  TYPE i
        height TYPE i.
    METHODS place_ant
      IMPORTING
        x   TYPE i
        y   TYPE i
        dir TYPE direction.
    METHODS run
      IMPORTING
        turns TYPE i.
    METHODS print.
  PRIVATE SECTION.
    DATA height TYPE i.
    DATA width TYPE i.
    DATA current_x TYPE i.
    DATA current_y TYPE i.
    DATA current_dir TYPE direction.

    TYPES: BEGIN OF _coordinate,
             x     TYPE i,
             y     TYPE i,
             state TYPE i,
           END OF _coordinate,
           _grid TYPE SORTED TABLE OF _coordinate WITH UNIQUE KEY x y.
    DATA grid TYPE _grid.

ENDCLASS.

CLASS ant IMPLEMENTATION.

  METHOD constructor.

    me->height = height.
    me->width  = width.

  ENDMETHOD.

  METHOD place_ant.
    current_x   = x.
    current_y   = y.
    current_dir = dir.

    IF NOT line_exists( grid[ x = x y = y ] ).
      INSERT VALUE #(  x = x y = y state = 0 ) INTO TABLE grid.
    ENDIF.

  ENDMETHOD.

  METHOD run.

    DATA new_dir TYPE direction.

    DO turns TIMES.

      DATA(current_position_state) = grid[ x = current_x y = current_y ]-state.
      CASE current_position_state.
        WHEN 0.
          "right turn
          new_dir = SWITCH #( current_dir
                  WHEN dir_north THEN dir_east
                  WHEN dir_east THEN dir_south
                  WHEN dir_south THEN dir_west
                  WHEN dir_west THEN dir_north ).
        WHEN 1.
          "left turn
          new_dir = SWITCH #( current_dir
                  WHEN dir_north THEN dir_west
                  WHEN dir_west THEN dir_south
                  WHEN dir_south THEN dir_east
                  WHEN dir_east THEN dir_north ).
      ENDCASE.

      grid[ x = current_x y = current_y ]-state = SWITCH #( current_position_state WHEN 1 THEN 0 ELSE 1 ).


      CASE new_dir.
        WHEN dir_north.
          place_ant( x = current_x y     = current_y - 1 dir = new_dir ).
        WHEN dir_west.
          place_ant( x = current_x - 1 y = current_y     dir = new_dir ).
        WHEN dir_south.
          place_ant( x = current_x y     = current_y + 1 dir = new_dir ).
        WHEN dir_east.
          place_ant( x = current_x + 1 y = current_y     dir = new_dir ).
      ENDCASE.

    ENDDO.


  ENDMETHOD.

  METHOD print.

    DATA x TYPE i.
    DATA y TYPE i.
    DATA c TYPE c LENGTH 2.

    SET BLANK LINES ON.

    DO height TIMES.
      y = y + 1.
      x = 0.
      DO width TIMES.

        x = x + 1.
        IF line_exists( grid[ x = x y = y ] ).

          IF current_x = x AND current_y = y.
            c = SWITCH #( current_dir
                  WHEN dir_north THEN '/\'
                  WHEN dir_west THEN '=>'
                  WHEN dir_south THEN '\/'
                  WHEN dir_east THEN '<=' ).
          ELSE.
            c = space.
          ENDIF.

          CASE grid[ x = x y = y ]-state.
            WHEN 0.
              WRITE c COLOR COL_POSITIVE NO-GAP.
            WHEN 1.
              WRITE c COLOR COL_NEGATIVE NO-GAP.
          ENDCASE.
        ELSE.
          c = space.
          WRITE c COLOR COL_BACKGROUND NO-GAP.
        ENDIF.
      ENDDO.
      NEW-LINE.
    ENDDO.
  ENDMETHOD.

ENDCLASS.

PARAMETERS turns TYPE i DEFAULT 1.
PARAMETERS width TYPE i DEFAULT 40.
PARAMETERS height TYPE i DEFAULT 40.
PARAMETERS xpos TYPE i.
PARAMETERS ypos TYPE i.
PARAMETERS dir TYPE ant=>direction DEFAULT ant=>dir_west.

INITIALIZATION.
  xpos = width / 2.
  ypos = height / 2.

START-OF-SELECTION.
  DATA(myant) = NEW ant( width = width height = height ).
  myant->place_ant( x = xpos y = ypos dir = dir ).
  myant->run( turns ).
  myant->print( ).
