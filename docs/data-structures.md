# Internal Data Structures / Representations

## Users

Users are identified by their distinct `UserID` and internally mapped to their socket file descriptor and the chosen username by hash maps.


## Chats

| Property    | Size     | Type | Description                                                                                                      |
|-------------|----------|------|------------------------------------------------------------------------------------------------------------------|
| Chat ID     |   4 byte |      |                                                                                                                  |
| Max. Users  |   2 byte | uint | Describing how many users are allowed in the chat.                                                               |
| User Amount |   2 byte | uint | How many users are actually currently connected to the chat instance.                                            |
| User Map    |   8 byte | map* | Pointer to a map of booleans, taking the userid as the key and the value describing if they are still connected. |

