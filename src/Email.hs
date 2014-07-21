{-# LANGUAGE OverloadedStrings #-}

module Email where

import Control.Lens
import Data.Text (Text)
import qualified Network.AmazonEmailer.Client.Snap as E
import Application

fromEmail :: Text
fromEmail = "SITE_EMAIL"

fromName :: Text
fromName = "PROJECT_NAME"

sendEmail :: Text -> Text -> Text -> AppHandler ()
sendEmail to subj body = do
  e <- use env
  (case e of
     "devel" -> E.sendMessageVerbose
     _ -> E.sendMessage) (E.Email to fromEmail fromName subj body)
