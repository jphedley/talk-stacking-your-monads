{-# LANGUAGE Arrows                #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE TemplateHaskell       #-}
module Db.TransactionInternetTransfer
  ( TransactionInternetTransfer'(TransactionInternetTransfer)
  , NewTransactionInternetTransfer
  , TransactionInternetTransfer
  , transactionInternetTransferQuery
  , allTransactionInternetTransfers
  , getTransactionInternetTransfer
  , insertTransactionInternetTransfer
  , transactionInternetTransferTransactionId
  , transactionInternetTransferAccount
  , transactionInternetTransferRef
  ) where

import BasePrelude hiding (optional)

import Control.Lens
import Data.Profunctor.Product.TH (makeAdaptorAndInstance)
import Data.Text                  (Text)
import Opaleye

import Db.Internal

data TransactionInternetTransfer' a b c = TransactionInternetTransfer
  { _transactionInternetTransferTransactionId :: a
  , _transactionInternetTransferAccount       :: b
  , _transactionInternetTransferRef           :: c
  } deriving (Eq,Show)
makeLenses ''TransactionInternetTransfer'

type TransactionInternetTransfer = TransactionInternetTransfer' Int Int Text
type TransactionInternetTransferColumn = TransactionInternetTransfer'
  (Column PGInt4)
  (Column PGInt4)
  (Column PGText)

makeAdaptorAndInstance "pTransactionInternetTransfer" ''TransactionInternetTransfer'

type NewTransactionInternetTransfer = TransactionInternetTransfer' Int Int Text

type NewTransactionInternetTransferColumn = TransactionInternetTransfer'
  (Column PGInt4)
  (Column PGInt4)
  (Column PGText)

transactionInternetTransferTable :: Table NewTransactionInternetTransferColumn TransactionInternetTransferColumn
transactionInternetTransferTable = Table "transaction_internet_transfer" $ pTransactionInternetTransfer TransactionInternetTransfer
  { _transactionInternetTransferTransactionId = required "transaction_id"
  , _transactionInternetTransferAccount       = required "account"
  , _transactionInternetTransferRef           = required "ref"
  }

transactionInternetTransferQuery :: Query TransactionInternetTransferColumn
transactionInternetTransferQuery = queryTable transactionInternetTransferTable

allTransactionInternetTransfers :: CanDb c e m => m [TransactionInternetTransfer]
allTransactionInternetTransfers = liftQuery transactionInternetTransferQuery

getTransactionInternetTransfer :: CanDb c e m => Int -> m (Maybe TransactionInternetTransfer)
getTransactionInternetTransfer i = liftQueryFirst $ proc () -> do
  tc <- transactionInternetTransferQuery -< ()
  restrict -< tc^.transactionInternetTransferTransactionId .== pgInt4 i
  returnA -< tc

insertTransactionInternetTransfer :: CanDb c e m => NewTransactionInternetTransfer -> m Int
insertTransactionInternetTransfer =
  liftInsertReturningFirst transactionInternetTransferTable (view transactionInternetTransferTransactionId)
  . packNew

packNew :: NewTransactionInternetTransfer -> NewTransactionInternetTransferColumn
packNew = pTransactionInternetTransfer TransactionInternetTransfer
  { _transactionInternetTransferTransactionId = pgInt4
  , _transactionInternetTransferAccount       = pgInt4
  , _transactionInternetTransferRef           = pgStrictText
  }
