# Binary-Protocol

The protocol should enable fast and efficiently bundled information about a chatting and metadata exchange with the server.
Furthermore, this should be an `opt-in` kind of protocol, where a user with a supported client-program can receive metadata while users with raw text like [`nc`](https://linux.die.net/man/1/nc) clients would receive preformatted text.

There is a clear client-server distinction in the protocol, where clients must interpret the protocol differently to servers (as the `Message type` for example can hold different flags whether its coming from a server or client)


***Definitions***
To keep a consistent tone, in the doc, the following definitions are used:

- Transmission = one block of continuous 
- Message      = a property of the transmission containing variable data

## Important Metadata / Transmission Properties

<!-- TODO: merge with arch-state -->

| Property     | Size                | Description                                                                                                                                                                                            |
|--------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Magic bytes  |              8 byte | "0x99 0x61 0x73 0x6D 0x63 0x68 0x61 0x74 0x0A" which is 0x99 + (asmchat). Where the 0x99 falls outside of the ascii range and thus disables wrongfully reading the following binary protocol as ascii. |
| Version      |              4 byte | 8bit major, 8bit minor, 16bit patch                                                                                                                                                                    |
| Message type |              1 byte | To differentiate between `PROT_MSG_CHAT`, `PROT_MSG_COMMAND`, `PROT_MSG_DISCONNECT` and potential future flags. [reference](./server/src/constants/protocol.inc)                                       |
|        Pad 3 |              3 byte | Padding                                                                                                                                                                                                |
| Message Len  |              2 byte |                                                                                                                                                                                                        |
| Message      | 1024 byte (maximum) |                                                                                                                                                                                                        |


## Transmission Layout

             Version   Padding          Message
              ↓          ↓                ↓
|--------------------------------------------------|
| ######## | #### | # | ### | ## | ############*** |
|--------------------------------------------------|
   ↑                ↑         ↑
  magic bytes     Type    Message Length


## Supported Actions

- Authenticate / Initialize
- Chat Message
- 


## Endpoints / Routing

This protocol supports actions based on the `Message Type` property, instead of maintaining separate routes or endpoints.
To support this variance, the `Message` property cannot and does not define itself with one clear type. As the server might respond to a `PROT_MSG_AUTH` 
The


## Byte-Order

The protocol uses little-endian encoding.




## Message Layouts

<!-- TODO: fill out each C-like function -->

### Client Messages

<details>
    <summary>PROT_MSG_AUTH</summary>

    > ~C-Like function~
    > uint prot_auth();

    This is the authentication message, which a client sends after the connection is established.
    The server will respond with a 4 byte unsigned integer on success and a 0 on failure.

    The returned value is the unique identifier linked to your socket. Must be used for PROT_MSG_CHAT etc.


</details>

<details>
    <summary>PROT_MSG_CHAT</summary>

    > ~C-Like function~
    > void prot_chat();

    This is the default chat message.

    | Property    | Size                | Description                       |
    |-------------|---------------------|-----------------------------------|
    | Sender      |              4 byte | Unique id of the Sender.          |
    | Recipient   |              4 byte | Unique id of the Sender.          |
    | Chat Length |              2 byte | Length of the subsequent message. |
    | Chat        | 1014 byte (maximum) |                                   |


</details>

<details>
    <summary>PROT_MSG_COMMAND</summary>

    >
    > void prot_command();

    This is a feature to be implemented but though of to be similar to like minecraft commands, with /my-command.

    | Property    | Size                | Description                       |
    |-------------|---------------------|-----------------------------------|
    |             |                     |                                   |

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

    <details>
        <summary></summary>
    </details>
-->

<details>
    <summary>PROT_MSG_DISCONNECT</summary>

    > ~C-Like function~
    > prot_disconnect()

    Disconnect

</details>


### Server Messages

