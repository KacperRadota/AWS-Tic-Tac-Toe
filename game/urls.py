from django.urls import path
from game.views import *

urlpatterns = [
    path('', index),
    path('game/<int:roomID>/<str:name>/', game)
]
