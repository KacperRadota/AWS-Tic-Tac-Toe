from django.shortcuts import render, redirect
from django.contrib import messages
from game.models import *


def index(request):
    if request.method == "GET":
        return render(request, "index.html")
    elif request.method == "POST":
        roomID = request.POST.get("room-id", None)
        playerName = request.POST.get("player-name", "Anonymous")
        if roomID:
            try:
                room = Room.objects.get(id=roomID)
                return redirect(f"/game/{room.id}/{playerName}/")
            except Room.DoesNotExist:
                messages.error(request, "Room does not exist.")
                return redirect(f"/")
        else:
            room = Room.objects.create()
            return redirect(f"/game/{room.id}/{playerName}/")


def game(request, roomID=None, name=None):
    try:
        room = Room.objects.get(id=roomID)
        return render(request, "game.html", {"room": room, "name": name})
    except Room.DoesNotExist:
        messages.error(request, "Room does not exist.")
        return redirect(f"/")
