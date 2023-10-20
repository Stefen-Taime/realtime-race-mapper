import stomp
import sys
import time
import json

def send_message(conn, topic, message):
    message_str = json.dumps(message)
    conn.send(destination=topic, body=message_str)

def main():
    broker_url, broker_port, username, password, topic, file_path = sys.argv[1:]
    broker_port = int(broker_port)  
    conn = stomp.Connection12(host_and_ports=[(broker_url, broker_port)])
    conn.connect(username=username, passcode=password, wait=True)

    try:
        
        with open(file_path, 'r') as file:
            for line in file:
                # Parse la ligne comme JSON
                message_json = json.loads(line.strip())
                print(f'Sending: {message_json}')
                send_message(conn, topic, message_json)
                time.sleep(1)  
    finally:
        conn.disconnect()

    print('Disconnected from ActiveMQ.')

if __name__ == '__main__':
    main()

