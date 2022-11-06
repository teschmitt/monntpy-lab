#!/usr/bin/python3

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
    "Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz",
    "jagt im komplett verwahrlosten Taxi quer durch Bayern. Zwölf Boxkämpfer jagen",
    "Viktor quer über den großen Sylter.",
    "200 CHARS",
]


async def post_articles(
    server: nntplib.NNTP, art_num: int, ident_str: str
):
    full_article = article_template.copy()
    full_article[2] = f"Newsgroups: {TESTING_GROUP}"
    full_article_b = list(map(lambda line: line.encode(), full_article))

    for i in range(art_num):
        full_article_b[
            1
        ] = f"Subject: {ident_str} - {article_template[1]} Article {i + 1} of {art_num}".encode()
        server.post(full_article_b)


async def main():
    await post_articles(
        server=nntplib.NNTP(host="127.0.0.1", port=1190),
        art_num=NUM_ARTICLES,
        ident_str="Spool performance",
    )


if __name__ == "__main__":
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    asyncio.run(main())
