module PFact (pfact) where

import Prelude
import Data.List
import Data.Maybe

import SafeRand
import Primality

--import Debug.Trace
--debug = (flip trace) False

rounds = 5

-- Generator functions
-- Pseudorandom orbits over the quadratic residues modulo N
generatora :: Integer -> Integer -> Integer -> Integer
generatora b a m = (b^2 + a) `rem` m

generatorb :: Integer -> Integer -> Integer
generatorb b m = (b^2 - 1) `rem` m

generatorc :: Integer -> Integer -> Integer
generatorc b m = (b^2 + 1) `rem` m

prho' :: Integer -> Integer -> Integer -> Maybe Integer
prho' n x y
  | a == b = Nothing
  | p >  1 = Just p
  | p == 1 = prho' n a b
  where a = generatorc x n
        b = generatorc (generatorc y n) n
        p = gcd (abs (b-a)) n

prho :: Integer -> Integer -> Integer -> Integer
prho n s c
--prho n s t | trace ("prho " ++ show n ++ " " ++ show s ++ " " ++ show t) False = undefined
  | c == 0 = n
  | q == ProbablyPrime = n
  | p == Nothing = prho n (lcgLehmer s) $ c-1 -- Pollard's Rho failed so permute the constant and try again
  | otherwise = fromJust p
  where q = prime n s
        p = prho' n s s

factorize :: Integer -> Integer -> [Integer]
factorize n s
  | even n    = [2] ++ factorize (quot n 2) s
  | n == 1    = [ ]
  | n == z    = [n]
  | otherwise = factorize z s ++ factorize (quot n z) s
  where z = prho n s rounds
  
pfact :: Integer -> Integer -> [Integer]
pfact n s
  | n < 2 = [n]
  | otherwise = sort . factorize n $ s