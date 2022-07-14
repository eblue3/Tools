SELECT [AlertObjectID], [AlertNote], [EntityCaption] FROM dbo.AlertObjects WHERE AlertObjectID = 2382 UPDATE AlertObjects SET AlertNote='cc111' WHERE AlertObjectId=2382

SELECT EventType, timestamp, accountid, AlertObjectid FROM dbo.AlertHistory WHERE AlertObjectID = 2382 INSERT INTO [AlertHistory] (EventType, timestamp, AccountID, AlertObjectID, Message, AlertActiveID) OUTPUT inserted.AlertHistoryID VALUES(3,Dateadd(SECOND, -25200, Getdate()),'admin',2382,'cc111',66548)
