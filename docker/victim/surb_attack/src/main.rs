use futures::{SinkExt, StreamExt};
use nym_client_websocket_requests::{requests::ClientRequest, responses::ServerResponse};
use nym_sphinx::addressing::clients::Recipient;
use tokio::net::TcpStream;
use tokio_tungstenite::{
    connect_async, tungstenite::protocol::Message, MaybeTlsStream, WebSocketStream,
};

async fn send_file_with_surbs(ws_stream: &mut WebSocketStream<MaybeTlsStream<TcpStream>>, address_file: &str) {
    
    let recipient = Recipient::try_from_base58_string(std::fs::read_to_string(address_file).unwrap().trim_end()).unwrap();

    let read_data = std::fs::read("/root/surb_attack/src/dummy_file").unwrap();
    
    let send_request = ClientRequest::SendAnonymous {
        recipient,
        message: read_data,
        reply_surbs: 20,
        connection_id: Some(0),
    };
    
    println!("sending content of 'dummy_file' over the mix network...");
    ws_stream.send(Message::Binary(send_request.serialize())).await.unwrap();
}

// async fn send_file_without_surbs() {
//     let uri = "ws://localhost:1977";
//     let (mut ws_stream, _) = connect_async(uri).await.unwrap();

//     let recipient = Recipient::try_from_base58_string(std::fs::read_to_string("/nyx_volume/client2_address").unwrap().trim_end()).unwrap();

//     let read_data = std::fs::read("dummy_file").unwrap();

//     let send_request = ClientRequest::Send {
//         recipient,
//         message: read_data,
//         connection_id: Some(0),
//     };

//     println!("sending content of 'dummy_file' over the mix network...");
//     ws_stream.send(Message::Binary(send_request.serialize())).await.unwrap();
// }

#[tokio::main]
async fn main() {
    let uri = "ws://localhost:1977";
    let (mut ws_stream, _) = connect_async(uri).await.unwrap();
    println!("#############################");
    println!("Example without using replies");

    //send_file_without_surbs().await;

    println!("\n\n#############################");
    println!("Example using replies");

    let attacker1 = "/nyx_volume/attacker1_address";
    let attacker2 = "/nyx_volume/attacker2_address";
    let attacker3 = "/nyx_volume/attacker3_address";
    let attacker4 = "/nyx_volume/attacker4_address";
    let attacker5 = "/nyx_volume/attacker5_address";

    send_file_with_surbs(&mut ws_stream, attacker1).await;
    send_file_with_surbs(&mut ws_stream, attacker2).await;
    send_file_with_surbs(&mut ws_stream, attacker3).await;
    send_file_with_surbs(&mut ws_stream, attacker4).await;
    send_file_with_surbs(&mut ws_stream, attacker5).await;
}
