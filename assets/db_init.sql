CREATE TABLE t_User(
        id                      TEXT NOT NULL PRIMARY KEY
        ,[name]                 TEXT
        ,email                  TEXT
        ,birthDate              TEXT NOT NULL
        ,avatar                 TEXT
);
CREATE TABLE t_Post(
        id                      TEXT NOT NULL PRIMARY KEY
        ,created                TEXT NOT NULL
        ,[text]                 TEXT
        ,authorId               TEXT
        ,commentAmount         INTEGER NOT NULL
        ,authorAvatar           TEXT
        ,likesAmount            INTEGER NOT NULL
        ,FOREIGN KEY(authorId) REFERENCES t_User(id)
);
CREATE TABLE t_PostFile(
        id                      TEXT NOT NULL PRIMARY KEY
        ,[name]                 TEXT NOT NULL
        ,mimeType               TEXT NOT NULL
        ,link                   TEXT NOT NULL
        ,postId                 TEXT NOT NULL
        ,FOREIGN KEY(postId) REFERENCES t_Post(id)
);
CREATE TABLE t_PostLikeState(
        id                      TEXT NOT NULL PRIMARY KEY
        ,[isLiked]              INTEGER NOT NULL DEFAULT 0
        ,FOREIGN KEY(id) REFERENCES t_Post(id)
);
CREATE TABLE t_UserStatistics(
        id                              TEXT NOT NULL PRIMARY KEY
        ,userPostAmount                 INTEGER NOT NULL DEFAULT 0
        ,userSubscribersAmount          INTEGER NOT NULL DEFAULT 0
        ,userSubscriptionsAmount        INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE t_PostCommentLikes(
        postCommentId                   TEXT NOT NULL
        ,userId                         TEXT NOT NULL
        ,PRIMARY KEY (postCommentId, userId)
);
CREATE TABLE t_PostComment(
        id                      TEXT NOT NULL PRIMARY KEY
        ,[text]                 TEXT NOT NULL
        ,created                TEXT NOT NULL
        ,likes                  INTEGER NOT NULL
        ,authorId               TEXT NOT NULL
        ,postId                 TEXT NOT NULL
        ,FOREIGN KEY(postId) REFERENCES t_Post(id)
        ,FOREIGN KEY(authorId) REFERENCES t_User(id)
);