#!/usr/bin/python3 -u


import nntplib
import logging
import subprocess
import time


TESTING_GROUP = "eval.core.monntpy"
INTERVAL = 10

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


server = nntplib.NNTP(host="127.0.0.1", port=1190)
nodeid = subprocess.run(["dtnquery", "nodeid"], stdout=subprocess.PIPE).stdout.decode().split("/")[-2]
print(f"Got node ID: {nodeid}")

num = 1

article_template = [
    f"From: Gene Roddenberry <e.w.roddenberry@{nodeid}>",
    "Subject: ",
    "Newsgroups: eval.core.monntpy",
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
    full_article[1] = f"{full_article[1]} Article {num} from node {nodeid}"

    full_article.append(MSG_BODY)

    print(f"Sending article '{full_article[1]}'")
    server.post(list(map(lambda line: line.encode(), full_article)))
    num += 1

