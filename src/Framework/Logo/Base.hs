-- | The module contains the Base datatypes of the Framework.
module Framework.Logo.Base where

import Control.Concurrent.STM
import Control.Monad.Reader
import qualified Data.IntMap as IM
import qualified Data.Map as M
import Data.Array
import System.Random (StdGen)

-- | Following the NetLogo convention, PenMode is an Algebraic Data Type (ADT)
data PenMode = Down | Up | Erase

-- | The 'Turtle' datatype is a record with each field being a transactional variable (TVar) holding
-- an attribute value of 'Turtle'.
-- For now only the default turtle attributes are supported.
data Turtle = MkTurtle {
      who_ :: TVar Int,
      breed_ :: TVar String,
      color_ :: TVar Double,
      heading_ :: TVar Double,
      xcor_ :: TVar Double,
      ycor_ :: TVar Double,
      shape_ :: TVar String,
      label_ :: TVar String,
      label_color_ :: TVar Double,
      hiddenp_ :: TVar Bool,
      size_ :: TVar Double,
      pen_size_ :: TVar Double,
      pen_mode_ :: TVar PenMode
    }
              deriving (Eq)

-- | The 'Patch' datatype follows a similar philosophy with the 'Turtle' (ADT).
-- Each field is a transactional variable (TVar) storing an attribute value of 'Patch'
-- For now only the default patch attributes are supported.
data Patch = MkPatch {
      pxcor_ :: TVar Int,
      pycor_ :: TVar Int,
      pcolor_ :: TVar Double,
      plabel_ :: TVar String,
      plabel_color_ :: TVar Double
      }
           deriving (Eq)

-- | The 'Patches' ADT is an ordered map (dictionary) from coordinates (Int, Int) to 'Patch' data structures
type Patches = M.Map (Int, Int) Patch

-- | The 'Turtles' ADT is an 'IM.IntMap' from who indices to 'Turtle' data structures
type Turtles = IM.IntMap Turtle

-- | The 'Globals' structure is an array of Int-indices pointing to Double (for now) variables.
-- In the future it must be polymorphic on the container type.
type Globals = Array Int (TVar Double)

-- | The 'World' is the union of 'Patches' and 'Turtles'
data World = MkWorld Patches Turtles

-- | An 'AgentRef' is a reference to an agent of the framework.
data AgentRef = PatchRef (Int,Int) Patch
              | TurtleRef Int Turtle
              | ObserverRef     -- ^ 'ObserverRef' is needed to restrict the context of specific built-in functions. 
              | Nobody          -- ^ 'Nobody' is the null reference in NetLogo.
                deriving (Eq)

-- | The 'Context' datatype is a tuple of the global variables, the current agents of the 'World' (through a transactional variable), a caller reference 'AgentRef', a safe String-channel for Input/Output, and the current random seed in a TVar
type Context = (Globals, TVar World, AgentRef, TChan String, TVar StdGen)

-- | The enhanced STM monad having a particular calling context
type CSTM a = ReaderT Context STM a

-- | The enhanced IO monad having a particular calling context
type CIO a = ReaderT Context IO a


