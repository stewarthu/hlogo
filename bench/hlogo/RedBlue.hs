{-# LANGUAGE CPP, TemplateHaskell, NoImplicitPrelude #-}
-- Options: hwrap, vwrap
import Language.Logo

#ifndef NR_TURTLES
#define NR_TURTLES 10
#endif

args = ["--max-pxcor=100"
       ,"--max-pycor=100"
       ,"--min-pxcor=-100"
       ,"--min-pycor=-100"]

run ["setup", "go"]

setup = do
  ask (atomic $ do
         c <- one_of [black, black, black, black, black, black, black, black, red, blue]
         set_pcolor c) =<< patches
  create_turtles NR_TURTLES
  reset_ticks

go = forever $ do
  t <- ticks
  when (t==1000) stop
  ask behave =<< turtles
  tick

behave = do
  c <- pcolor
  atomic $ fd 1 >> if c == red
                   then lt 30
                   else when (c == blue) (rt 30)




