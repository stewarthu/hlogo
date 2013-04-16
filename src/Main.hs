{-# LANGUAGE TemplateHaskell #-}
module Main where

import Framework.Logo.Keyword
import Framework.Logo.Prim
import Framework.Logo.Exception
import Framework.Logo.Base
import Framework.Logo.Conf
import Control.Monad

globals ["g1", "g2", "g3"] -- Introduces g1, unsafe_g1, set_g1, with_g1 etc..
turtles_own ["t1", "t2"] -- Introduces t1, unsafe_t1, set_t1, with_t1 etc..
patches_own ["p1", "p2"] -- Introduces p1, unsafe_p1, set_p1, with_p1 etc..
links_own ["l1", "l2"]
breeds ["mice", "mouse"] -- create_mice, create_ordered_mice, mice, sprout_mice .. etc
breeds_own "mice" ["b1", "b2"] -- b1, unsafe_b1, set_b1, etc..
directed_link_breed ["arcs", "arc"] -- arcs, arc <from> <to>, create_arcs_to, create_arcs_from, etc..
undirected_link_breed ["edges", "edge"] -- edges, edge <from> <to>, create_edges_with , etc..
link_breeds_own "arcs" ["a1", "a2"] -- a1, unsafe_a1, set_a1, etc..
link_breeds_own "edges" ["e1", "e2"] -- a1, unsafe_a1, set_a1, etc..

setup = do
  ask_ (do
         [c] <- unsafe_one_of [black, black, black, black, black, black, black, black, red, blue]
         atomic $ set_pcolor c) =<< unsafe_patches
  atomic $ create_turtles 10000
  atomic $ reset_ticks
  -- snapshot -- Uncomment this line to draw a snapshot at tick=0.eps

go = forever $ do               -- go is a forever action, so it runs recursively until stop is called
  t <- unsafe_ticks
  when (t==1000) $ do
                 -- snapshot -- Uncomment this line to draw a snapshot at the last tick=1000 before stop 
                 stop
  ask_ (behave) =<< unsafe_turtles
  atomic $ tick

behave = do
  c <- unsafe_pcolor
  atomic $ fd 1 >> if c == red
                   then lt 30
                   else when (c == blue) (rt 30)

run ['setup, 'go]               -- this is a wrapper to tell which functions to call and in which order
