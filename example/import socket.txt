import socket
import threading

PC_IP = "0.0.0.0"
PC_PORT = 8091

ROBOT_IP = "192.168.20.55"
ROBOT_PORT = 8090

running = True

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((PC_IP, PC_PORT))
sock.settimeout(0.5)  # korte timeout zodat de receive-thread netjes kan stoppen


def receiver():
    """Ontvang berichten van de robot."""
    global running

    print(f"[RX] Luistert op {PC_IP}:{PC_PORT} ...")

    while running:
        try:
            data, addr = sock.recvfrom(4096)
            message = data.decode("ascii", errors="replace")
            print(f"\n[RX] Van {addr}: len={len(data)} hex={data.hex(' ')} text={message!r}")
            print("Te verzenden bericht: ", end="", flush=True)
        except socket.timeout:
            continue
        except OSError:
            break
        except Exception as e:
            print(f"\n[RX] Fout bij ontvangen: {e}")
            break


# Start receive-thread
rx_thread = threading.Thread(target=receiver, daemon=True)
rx_thread.start()

print("UDP sender + receiver gestart")
print(f"Lokaal gebonden op {PC_IP}:{PC_PORT}")
print(f"Target robot = {ROBOT_IP}:{ROBOT_PORT}")
print("Typ een bericht en druk op Enter.")
print("Typ 'quit' om te stoppen.\n")

try:
    while True:
        message = input("Te verzenden bericht: ").strip()

        if message.lower() == "quit":
            print("Programma wordt afgesloten.")
            running = False
            break

        if not message:
            print("Leeg bericht overgeslagen.")
            continue

        sock.sendto(message.encode("ascii"), (ROBOT_IP, ROBOT_PORT))
        print(f"[TX] Verzonden -> {message}")

finally:
    running = False
    sock.close()
    print("Socket gesloten.")
