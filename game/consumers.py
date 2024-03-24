import contextlib

from channels.generic.websocket import AsyncJsonWebsocketConsumer


class GameConsumer(AsyncJsonWebsocketConsumer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.roomID = None
        self.groupName = None

    async def connect(self):
        self.roomID = self.scope['url_route']['kwargs']['roomID']
        self.groupName = f"group_{self.roomID}"
        with contextlib.suppress(KeyError):
            if len(self.channel_layer.groups[self.groupName]) >= 2:
                await self.accept()
                await self.send_json({
                    "event": "show_error",
                    "error": "This room is full"
                })
                return await self.close()
        await self.accept()
        await self.channel_layer.group_add(self.groupName, self.channel_name)

    async def receive_json(self, content, **kwargs):
        print(content)
        return await super().receive_json(content, **kwargs)

    async def disconnect(self, code):
        return await super().disconnect(code)
