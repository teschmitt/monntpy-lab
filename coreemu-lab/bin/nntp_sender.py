#!/usr/bin/python3 -u

import logging
import nntplib
import subprocess
import sys
import socket
import time


# if argujments are not given, use default values
if len(sys.argv) < 3:
    print("Usage: nntp_sender.py <SERVER IP> <EMAIL> [<INTERVAL>]")
    sys.exit(1)
if len(sys.argv) > 3:
    INTERVAL = float(sys.argv[3])
else:
    INTERVAL = 5.0

print(f"Args: {sys.argv}")

server_ip = sys.argv[1]
email_address = sys.argv[2]
print(f"IP:     {server_ip}")
print(f"E-Mail: {email_address}")

TESTING_GROUP = "germany.hessen.darmstadt-dieburg.dieburg"


MSG_BODY = """
Corrupti commodi consequuntur fugiat corporis atque eaque,
libero ipsa facere optio possimus perspiciatis dolore animi,
voluptatem quia optio iure voluptatum hic aliquam, doloremque
dolore accusamus vitae est asperiores similique placeat omnis
porro? Facere quos commodi voluptatum excepturi animi
corrupti beatae nesciunt eveniet debitis, ducimus ipsum
consequatur fuga similique molestias corporis sunt, similique

fuga rem perferendis quia ad exercitationem error veniam,
quasi eum facilis repellendus earum? Fugiat optio magni
voluptatum aspernatur veritatis dignissimos consectetur
molestias quod asperiores, repellendus iusto totam possimus
cumque quidem alias incidunt, voluptatem est quas natus
dolorum illo cupiditate libero aliquam magnam ad, est dicta
numquam aperiam minus, excepturi cumque quam iusto sequi
veritatis asperiores atque blanditiis?
"""


server = nntplib.NNTP(host=server_ip, port=1190)

num = 1

article_template = [
    f"From: {email_address}",
    "Subject: ",
    f"Newsgroups: {TESTING_GROUP}",
    "MIME-Version: 1.0",
    "User-Agent: Full Monty v0.1",
    "Content-Type: text/plain; ",
    "Content-Transfer-Encoding: 8bit",
    "",
]

while True:
    print(f"Sleeping for {INTERVAL} seconds...")
    time.sleep(INTERVAL)
    full_article = []
    full_article.extend(article_template)
    full_article[1] = f"{full_article[1]} Article {num} from host {socket.gethostname()}"

    full_article.append(MSG_BODY)

    print(f"Sending article '{full_article[1]}'")
    server.post(list(map(lambda line: line.encode(), full_article)))
    num += 1

