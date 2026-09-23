# Internal Data Structures / Representations

## Users

Users are identified by their distinct `UserID` and internally mapped to their socket file descriptor and the chosen username by hash maps.


## Chats

| Property    | Size     | Description                                        |
|-------------|----------|----------------------------------------------------|
| Chat ID     |          |                                                    |
| Max. Users  |          |                                                    |
| User Amount |          |                                                    |
| Users       | Variable | Array of users, length described by `User Amount`. |


