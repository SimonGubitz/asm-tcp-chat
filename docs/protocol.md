# Binary-Protocol

The protocol should enable fast and efficiently bundled information about a chatting and metadata exchange with the server.
Furthermore, this should be an `opt-in` kind of protocol, where a user with a supported client-program can receive metadata while users with raw text like [`nc`](https://linux.die.net/man/1/nc) clients would receive preformatted text.

There is a clear client-server distinction in the protocol, where clients must interpret the protocol differently to servers (as the `Message type` for example can hold different flags whether its coming from a server or client)


***Definitions***
To keep a consistent tone, in the doc, the following definitions are used:

- Actions   = defined by the `Action / Message Type` property and responsible for the different interpretations of the data

- Frame     = the complete wire-level unit transmitted
- Header    = the fixed-size constant header transmitted in each frame
- Payload   = the variable-sized data described by the header transmitted in each frame

## Header Layout

| Property              | Size                | Description                                                                                                                                                                                                                                     |
|-----------------------|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Magic bytes           |              8 byte | "0x99 0x61 0x73 0x6D 0x63 0x68 0x61 0x74" which is 0x99 + the hexadecimal representation of the string "asmchat". Where the 0x99 falls outside of the ascii range and thus disables wrongfully reading the following binary protocol as ascii.  |
| Version               |              4 byte | 8bit major, 8bit minor, 16bit patch                                                                                                                                                                                                             |
| Action / Message type |              1 byte | To differentiate between `PROT_MSG_CHAT`, `PROT_MSG_COMMAND`, `PROT_MSG_DISCONNECT` and potential future flags. [reference](../server/src/constants/protocol.inc)                                                                               |
|                 Pad 3 |              3 byte | Padding to align the upcoming `Message Length` and `Message` to a 8 byte boundry.                                                                                                                                                               |
| Message Length        |              2 byte |                                                                                                                                                                                                                                                 |
| Message               | 1004 byte (maximum) |                                                                                                                                                                                                                                                 |


## Transmission Layout

```
             Version   Padding          Message
              ↓          ↓                ↓
|--------------------------------------------------|
| ######## | #### | # | ### | ## | ############*** |
|--------------------------------------------------|
   ↑                ↑         ↑
  magic bytes     Type    Message Length
```


## Supported Actions

- Authenticate / Initialize
- Chat Message
- Join a Chat-Room
- Create a Chat-Room
- Search Chat-Rooms ???


## Endpoints / Routing

This protocol supports actions based on the `Message Type` property, instead of maintaining separate routes or endpoints.
To support this variance, the `Message` property cannot and does not define itself with one clear type. As the server might respond to a `PROT_MSG_AUTH` 


## Byte-Order

The protocol uses little-endian encoding. To reduce unnecessary byte swaps in parsing.
View the related [benchmarks](./benchmarks.md#byte-order).


## Message Layouts

<!-- TODO: fill out each C-like function -->

### Client Messages

<details>
    <summary>PROT_AUTH</summary>

    > ~C-Like function~
    > uint prot_auth();

    This is the authentication message, which a client sends after the connection is established.
    The server will respond with a 4 byte unsigned integer on success and a 0 on failure.

    The returned value is the unique identifier linked to your socket. Must be used for PROT_MSG_CHAT etc.

    ***Request Layout:***
    | Property    | Size                | Description                    |
    |-------------|---------------------|--------------------------------|
    | Username    | 16 byte             | The                            |

    ***Response:***
    The server will respond with a `PROT_SRV_AUTH` response.

</details>

<details>
    <summary>PROT_MSG_CHAT</summary>

    > ~C-Like function~
    > void prot_chat();

    This is the default chat message.

    ***Request Layout:***
    | Property    | Size                | Description                    |
    |-------------|---------------------|--------------------------------|
    | Sender      |              4 byte | Unique id of the Sender.       |
    | Recipient   |              4 byte | Unique id of the Sender.       |
    | Chat length |                     |                                |
    | Chat        |  994 byte (maximum) |                                |


</details>

<!-- TODO: WHY IS THIS HERE??  -->
<details>

    <summary>PROT_JOIN_CHAT</summary>

    > ~C-Like function~
    > void prot_join_chat();


    ***Request Layout:***
    | Property    | Size                | Description                    |
    |-------------|---------------------|--------------------------------|
    |             |                     |                                |

    ***Response:***
    Normally there won't be a response.
    If there was an error, a `PROT_SRV_ERROR` will be sent.

</details>

<details>
    <summary>PROT_REQ_HIST</summary>

    > ~C-Like function~
    > void prot_req_hist();

    ***Request Layout:***
    | Property    | Size                | Description                    |
    |-------------|---------------------|--------------------------------|
    |             |                     |                                |

    ***Response:***
    The server will response with a `PROT_SRV_HIST` response.

</details>

<!-- 
    <details>
        <summary></summary>
    </details>

    <details>
        <summary></summary>
    </details>

    <details>
        <summary></summary>
    </details>
-->

<details>
    <summary>PROT_DISCONNECT</summary>

    > ~C-Like function~
    > prot_disconnect()

    Disconnect

</details>


### Server Messages

- PROT_SRV_AUTH         -> acknowledge and confirm the username or potentially if the username already exists
- PROT_SRV_JOIN_CHAT    -> return special data requested by the specific command
- PROT_SRV_HIST         -> return the chat history

