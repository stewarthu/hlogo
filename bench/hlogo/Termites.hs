-- Options: max-pxcor: 100, max-pycor: 100, no-hwrap, no-vwrap
-- turtles: termites
-- patches: wood chips
import Language.Logo

density = 20
number = 400

run ["setup", "go"]

setup = do
  ask (atomic $ do
         r <- random_float 100
         when (r < density) $ set_pcolor yellow) =<< patches

  ts <- atomic $ create_turtles number
  ask (atomic $ do
         x <- random_xcor
         y <- random_ycor
         set_color white
         setxy x y
         set_size 5) ts
  atomic $ reset_ticks

go = forever $ do
  t <- ticks
  when (t > 100) stop
  ask (do 
        search_for_chip
        find_new_pile
        put_down_chip
      ) =<< turtles
  atomic $ tick


search_for_chip = do
  c <- pcolor
  if (c == yellow)
    then atomic $ do
      set_pcolor black
      set_color orange
      fd 20
    else do
      wiggle
      search_for_chip

find_new_pile = do
  c <- pcolor
  when (c /= yellow) $ do
                  wiggle
                  find_new_pile

put_down_chip = do
  c <- pcolor
  if (c == black) 
    then do
      atomic $ do
           set_pcolor yellow
           set_color white
           get_away
    else do
      atomic $ random 360 >>= rt >> fd 1
      put_down_chip
    
get_away = do
  r <- random 360
  rt r
  fd 20
  c <- pcolor
  when (c /= black) get_away

wiggle = atomic $ do
  r1 <- random 50
  r2 <- random 50
  fd 1
  rt r1
  lt r2


