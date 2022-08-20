#!/usr/local/bin/python3

import asyncio
import nntplib
import logging
import sys

from typing import List

TESTING_GROUP = "monntpy.eval"

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <num-articles>")
    sys.exit(1)
NUM_ARTICLES = int(sys.argv[1])

article_template = [
    "From: Thomas Schmitt <t.e.schmitt@posteo.de>",
    "Subject:",
    "Newsgroups:",
    "MIME-Version: 1.0",
    "User-Agent: Full Monty v0.1",
    "Content-Type: text/plain; ",
    "Content-Transfer-Encoding: 8bit",
    "",
]


async def post_articles(
    server: nntplib.NNTP, art_num: int, art_length: str, ident_str: str
):
    if art_length not in ["short", "med", "long"]:
        raise ValueError("art_length must be either 'short', 'med' or 'long'")
    full_article = []
    full_article.extend(article_template)
    full_article[2] = f"Newsgroups: {TESTING_GROUP}"

    body = open(f"articles/{art_length}_text").readlines()
    full_article.extend(map(lambda line: line.strip(), body))
    full_article_b = list(map(lambda line: line.encode(), full_article))

    for i in range(art_num):
        full_article_b[
            1
        ] = f"Subject: {ident_str} - {article_template[1]} Article {i + 1} of {art_num}".encode()
        server.post(full_article_b)


async def main():
    # server: List[nntplib.NNTP] = [
    #     nntplib.NNTP(host="127.0.0.1", port=1190) for _ in range(2)
    # ]
    # for s in server:
    #     s.group(TESTING_GROUP)
    #
    # await asyncio.gather(
    #     (post_articles(server=s, art_num=1, art_length="long", ident_str=f"{s}") for s in server)
    # )

    await post_articles(
        server=nntplib.NNTP(host="127.0.0.1", port=1190),
        art_num=NUM_ARTICLES,
        art_length="short",
        ident_str="Spool performance",
    )


if __name__ == "__main__":
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    # print("Connecting ...")
    # s = nntplib.NNTP(host="127.0.0.1", port=1190)
    # print("Connected!")

    # _, count, first, last, name = s.group(TESTING_GROUP)
    # logger.debug(s.group(TESTING_GROUP))

    asyncio.run(main())
