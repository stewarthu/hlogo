{-# LANGUAGE CPP #-}
{-# OPTIONS_HADDOCK show-extensions #-}
-- | 
-- Module      :  Language.Logo.Core
-- Copyright   :  (c) 2013-2015, the HLogo team
-- License     :  BSD3
-- Maintainer  :  Nikolaos Bezirgiannis <bezirgia@cwi.nl>
-- Stability   :  experimental
--
-- The core long-lived components of the simulation engine
module Language.Logo.Core (
                           cInit
                          ,__tick
                          ,__who
                          ,__timer 
                          ,__tg
                          -- ,__turtles
                          ,__patches
) where

import Control.Concurrent (forkIO)
import Control.Concurrent.STM
import Language.Logo.Conf
import Language.Logo.Base
import qualified Data.Map as M (empty)
import qualified  Data.IntMap as IM (empty)
import Data.Array (listArray)
import Data.Time.Clock (UTCTime,getCurrentTime)
import Control.Monad
import System.Random (mkStdGen)
import System.IO.Unsafe (unsafePerformIO)
--import qualified Data.Vector.Mutable as MV (new)
import Data.IORef (IORef, newIORef, writeIORef)
import qualified Control.Concurrent.Thread.Group as ThreadG (ThreadGroup, new)
#if __GLASGOW_HASKELL__ < 710
import Control.Applicative
#endif

{-# NOINLINE __tick #-}
-- | The global (atomically-modifiable) tick variable
--
-- Double because NetLogo also allows different than 1-tick increments
__tick :: IORef Double
__tick = unsafePerformIO $ newIORef undefined

{-# NOINLINE __who #-}
-- | The global (atomically-modifiable) who-counter variable
__who :: TVar Int
__who = unsafePerformIO $ newTVarIO undefined

{-# NOINLINE __timer #-}
-- | The global (atomically-modifiable) timer variable
__timer :: TVar UTCTime
__timer = unsafePerformIO $ newTVarIO undefined

{-# NOINLINE __tg #-}
-- | The global group of running threads. Observer uses this ThreadGroup in 'ask', as a synchronization point to wait until all of them are finished.
__tg :: ThreadG.ThreadGroup
__tg = unsafePerformIO $ ThreadG.new

-- {-# NOINLINE __turtles #-}
-- -- | The global turtles vector
-- __turtles :: TVar Turtles_
-- __turtles = unsafePerformIO $ newTVarIO =<< MV.new 0

{-# NOINLINE __patches #-}
-- | The global turtles vector
__patches :: Patches
__patches = listArray ((min_pxcor_ conf, min_pycor_ conf), (max_pxcor_ conf, max_pycor_ conf))
            (unsafePerformIO $ sequence [newPatch x y | x <- [min_pxcor_ conf..max_pxcor_ conf], y <- [min_pycor_ conf..max_pycor_ conf]])


-- | Reads the Configuration, initializes globals to 0, spawns the Patches, and forks the IO Printer.
-- Takes the length of the patch var from TH (trick) for the patches own array.
-- Returns the top-level Observer context.
cInit :: Int -> IO Context
cInit po = do
  -- read dimensions from conf
  t <- getCurrentTime
  -- initialize globals
  writeIORef __tick 0
  atomically $ do
                writeTVar __who 0
                writeTVar __timer t
  -- initialize
  let ts = IM.empty
  let ls = M.empty
  tw <- newTVarIO (MkWorld ts ls)
  tp <- newTQueueIO
  g <- newTVarIO (mkStdGen 0)   -- default StdGen seed equals 0
  forkIO $ printer tp
  return (tw, ObserverRef g, tp, Nobody)
  where
    -- | The printer just reads an IO chan for incoming text and outputs it to standard output.
    printer:: TQueue String -> IO ()
    printer tp = forever $ do
                   v <- atomically $ readTQueue tp
                   putStrLn v

-- | Returns a 'Patch' structure with default arguments (based on NetLogo)
newPatch :: Int -> Int -> IO Patch
newPatch x y = let po = 1       -- patches_own only one element for now
               in MkPatch <$>
               newTVarIO 0 <*>
               newTVarIO "" <*>
               newTVarIO 9.9 <*>
               -- init the patches-own variables to 0
               (return . listArray (0, po -1) =<< replicateM po (newTVarIO 0)) <*>
               newTVarIO (mkStdGen (x + y * 1000))
#ifdef STATS_STM
               <*> pure (unsafePerformIO (newIORef 0)) <*> pure (unsafePerformIO (newIORef 0))
#endif



