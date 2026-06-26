import socket

LISTEN_IP = "0.0.0.0"
LISTEN_PORT = 8091

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((LISTEN_IP, LISTEN_PORT))

print(f"UDP echo server luistert op {LISTEN_IP}:{LISTEN_PORT} ...")

while True:
        try:
            data, addr = sock.recvfrom(4096)
            message = data.decode(errors='replace')
            print(f"Ontvangen van {addr}: {message}")

            reply = f"PONG_ACK:{message}"
            sock.sendto(reply.encode(), addr)
            print(f"Teruggestuurd naar {addr}: {reply}")
        except KeyboardInterrupt:
            print("\nServer gestopt.")
            sock.close()