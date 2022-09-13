import asyncio


runloop1 = False


async def loop1():
    global runloop1
    while True:
        print(f"{runloop1=}")
        await asyncio.sleep(0.2)


async def loop2():
    global runloop1
    while True:
        runloop1 = not runloop1
        await asyncio.sleep(1)

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    asyncio.create_task(loop1())
    asyncio.run(loop2())
